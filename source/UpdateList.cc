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

      for (unsigned int dl=0; dl < no_downloads; dl++) {
	DownloadInfo& info=package.download.download_infos[dl];

	if (info.protocol=="http" || info.protocol=="ftp") {
	  dl.Download(info.url);
	}

      }
    }
}
