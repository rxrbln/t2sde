#include <ostream>
#include "desc-parser.hh"
#include "Curl.hh"


int main (int argc, char* argv[])
{
  Package package;
  
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
	  std::cout << "trying to download listing of " << info.url << std::endl;
	  std::cout.flush();
	  dl.Download(info.url);
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
