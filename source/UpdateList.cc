#include <ostream>
#include "desc-parser.hh"
#include "Curl.hh"

std::vector <std::string> suffixes;

void GenList (std::string templ, std::ifstream& s, bool quote_mode) {

  std::cout << templ << " ---> ";

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

  std::cout << prefix << "?" << suffix << std::endl;

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
	  length--;

	std::string matched=token.substr(begin, length);

	std::cout << matched << std::endl;
      }


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
