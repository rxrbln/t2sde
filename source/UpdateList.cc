#include <ostream>
#include "desc-parser.hh"
#include "Curl.hh"
#include "ctype.h"

std::vector <std::string> suffixes;

unsigned int GetNumber (std::string& s, std::string::size_type start, std::string::size_type end) {
  std::string::size_type number_length = end - start;
  std::string found_number_string = s.substr(start, number_length);
  //  std::cout << found_number_string << std::endl;
  unsigned int found_number = (unsigned int) atoi(found_number_string.c_str());
  return found_number;
}

int CmpVersions(std::vector<unsigned int>& a, std::vector<unsigned int>& b) {
  for (unsigned int i = 0; i < std::min(a.size(), b.size()); i++) {
    if (a[i] < b[i])
      return -1;
    if (a[i] > b[i])
      return 1;
  }
  return 0;
}

void ExtractNumbers (std::string& s, std::vector<unsigned int>& output) {
  std::string::size_type number_start = std::string::npos;

  output.clear ();

  for (std::string::size_type s_pos=0; s_pos < s.length(); s_pos++) {
    if (isdigit(s[s_pos])) {
      if (number_start == std::string::npos)
	number_start = s_pos;
    } else if (number_start != std::string::npos) {
      output.push_back(GetNumber(s, number_start, s_pos));
      number_start = std::string::npos;
    }
  }
  
  if (number_start != std::string::npos)
    output.push_back(GetNumber(s, number_start, s.length()));
}

void GenList (std::string file, std::ifstream& s, bool quote_mode) {
  std::vector <std::string> hits;
  std::vector <unsigned int> file_version;
  std::vector <unsigned int> hit_version;

  std::string templ=file;
  std::string suffix = "";

  for (unsigned int i=0; i < suffixes.size(); i++) {
    std::string& test=suffixes[i];
    std::string::size_type s_pos=templ.length() - test.length();
    //    std::cout << templ.substr(s_pos, test.length()) << std::endl;
    if (templ.substr(s_pos, test.length()) == test) {
      suffix=test;
      templ = templ.substr(0, s_pos);
    }
  }

  ExtractNumbers(templ, file_version);

  std::string prefix;

  std::string::size_type idx = templ.find('-');
  if (idx == std::string::npos)
    prefix=templ;
  else {
    prefix = templ.substr(0,idx);
    prefix += "-";
  }

  if (quote_mode) {
    prefix = "\"" + prefix;
    suffix += "\"";
  }

  std::cout << file << "(v";
  for (unsigned int i=0; i < file_version.size(); i++) {
    std::cout << "." << file_version[i];
  }
  std::cout << ") ---> " << prefix << "?" << suffix << std::endl;

  std::string token;
  while (!s.eof()) {
    s >> token;

    idx = token.find(prefix);

    if (idx != std::string::npos) {
      //      std::cout << token << std::endl;
      std::string::size_type idx2;

      if (suffix.length() > 0)
	idx2=token.find(suffix, idx+1);
      else {
	idx2=token.find(' ', idx+1);
	if (idx2 == std::string::npos)
	  idx2=token.length() - 1;
      }

      if (idx2 != std::string::npos) {
	std::string::size_type begin = (quote_mode) ? idx+1 : idx;
	std::string::size_type length = (idx2-idx)+suffix.length();
	if (quote_mode)
	  length -= 2;

	std::string matched=token.substr(begin, length);

	hits.push_back(matched);
      }

    }
  }



  for (unsigned int i = 0; i < hits.size(); i++) {
    std::string base = hits[i].substr(0, hits[i].length()+1-suffix.length());
    //    std::cout << base << std::endl;
    ExtractNumbers(base, hit_version);

    int sign = 0;
    if(hits[i] != file) {
      sign = CmpVersions(hit_version, file_version);
      if (sign >= 0)
	sign++;
    }

    std::cout << "[MATCH] '" << hits[i] << "' (v";
    for (unsigned int j=0; j < hit_version.size(); j++) {
      std::cout << "." << hit_version[j];
    }
    std::cout << ")";
    switch (sign) {
    case 0:
      std::cout << " [=]" << std::endl;
      break;
    case 1:
      std::cout << " [?]" << std::endl;
      break;
    case 2:
      std::cout << " [+]" << std::endl;
      break;
    case -1:
      std::cout << " [-]" << std::endl;
      break;
    }
  
  }
  
}


int main (int argc, char* argv[])
{
  Package package;

  suffixes.push_back(".tar.gz");
  suffixes.push_back(".gz");
  suffixes.push_back(".tar.bz2");
  suffixes.push_back(".bz2");
  suffixes.push_back(".tgz");

  for (int i = 1; i < argc; ++i)
    {
      package.Clear();
      package.ParsePackage (argv[i]);

      unsigned int no_downloads = package.download.download_infos.size();

      CurlWrapper dl;
      dl.SetConnectTimeout(15);
      dl.SetMaxTime(30);

      for (unsigned int dln=0; dln < no_downloads; dln++) {
	DownloadInfo& info=package.download.download_infos[dln];

	try {
	  if (info.protocol == "http" || info.protocol == "ftp") {
	  std::cout << "trying to download listing of " << info.url << std::endl;
	  std::cout.flush();

	  dl.Download(info.url, 0, 200000);

	  std::ifstream* s=dl.OpenFile();
	  GenList(info.file, *s, info.protocol=="http");
	  s -> close();
	  }
	}
	catch (TimeoutException e) {
	  std::cout << "Operation timeout" << std::endl;
	}
	catch (UnsupportedProtocolException e) {
	  std::cout << "Unsupported protocol : " << info.protocol << std::endl;
	}
	catch (MalformedUrlException e) {
	  std::cout << "Malformed URL or invalid URL options" << info.url << std::endl;
	}
	catch (ConnectErrorException e) {
	  std::cout << "Could not connect to host" << std::endl;
	}
	catch (AccessDeniedException e) {
	  std::cout << "Access denied or invalid user/pass" << std::endl;
	}
	catch (DoesNotExistException e) {
	  std::cout << "File does not exist" << std::endl;
	}
	catch (CurlException e) {
	  std::cout << "operation canceled due to errors executing '" << dl.GetCommand() << "'" << std::endl;
	}

      }

      dl.RemoveFile();
    }
}
