#include <ostream>
#include "desc-parser.hh"
#include "Curl.hh"
#include "ctype.h"

#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <glob.h>

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

class Match
{
public:
  Match (const std::string& i_name, const std::string& suffix)
  {
    name = i_name;
    std::string base = name.substr(0, name.length()+1-suffix.length());
    ExtractNumbers(base, version);
  }

  std::string name;
  std::vector <unsigned int> version;
};

class VersionComparator
{
public:
  bool operator() (Match* a, Match* b)
  {
    return CmpVersions(a -> version, b -> version) > 0;
  }
};

void GenList (std::string file, std::ifstream& s, bool quote_mode) {
  std::vector <Match> matches;
  std::vector <Match*> newer_versions;
  std::vector <unsigned int> file_version;

  // search for a matching extension
  std::string templ = file;
  std::string suffix = "";

  for (unsigned int i = 0; i < suffixes.size(); ++i) {
    std::string& test = suffixes[i];
    std::string::size_type s_pos = templ.rfind(test);
    if (s_pos != std::string::npos) {
      suffix = test;
      templ = templ.substr(0, s_pos);
      break;
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

	matches.push_back(Match(matched, suffix));
      }

    }
  }



  for (unsigned int i = 0; i < matches.size(); i++) {

    int sign = 0;
    if(matches[i].name != file) {
      sign = CmpVersions(matches[i].version, file_version);
      if (sign >= 0)
	sign++;
    }

    std::cout << "[MATCH] '" << matches[i].name << "' (v";
    for (unsigned int j=0; j < matches[i].version.size(); j++) {
      std::cout << "." << matches[i].version[j];
    }
    std::cout << ")";
    switch (sign) {
    case 0:
      std::cout << " [=]" << std::endl;
      break;
    case 1:
      std::cout << " [?]" << std::endl;
      newer_versions.push_back(&matches[i]);
      break;
    case 2:
      std::cout << " [+]" << std::endl;
      newer_versions.push_back(&matches[i]);
      break;
    case -1:
      std::cout << " [-]" << std::endl;
      break;
    }
  
  }
  
  std::cout << "-----------------------" << std::endl;

  std::sort(newer_versions.begin(), newer_versions.end(), VersionComparator());
  for (unsigned int i=0; i < newer_versions.size(); i++) {
    if (i == 0 || newer_versions[i-1] -> name != newer_versions[i] -> name)
      std::cout << newer_versions[i] -> name << std::endl;
  }
    

  std::cout << "-----------------------" << std::endl;

}


int main (int argc, char* argv[])
{
  suffixes.push_back(".tar.bz2");
  suffixes.push_back(".tar.gz");
  suffixes.push_back(".tbz2");
  suffixes.push_back(".tgz");
  suffixes.push_back(".bz2");
  suffixes.push_back(".gz");

  Package package;

  for (int i = 1; i < argc; ++i)
    {
      package.Clear();

      // check if package name or path is given
      std::string fname = argv[i];
      struct stat statbuf;
      if (stat(fname.c_str(), &statbuf)) {
	fname = "package/*/" + fname + "/" + fname + ".desc";
	// std::cout << "Checking " << fname << std::endl;

	glob_t globbuf;
	if (glob(fname.c_str(), GLOB_ERR, NULL, &globbuf) == 0) {
	  fname = globbuf.gl_pathv[0];
	  // std::cout << "Found " << fname << std::endl;
	}
	globfree(&globbuf);
      }

      // parse package ...
      package.ParsePackage (fname);

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
