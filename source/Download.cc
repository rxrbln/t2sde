
#include <ostream>

#include "desc-parser.hh"

int main (int argc, char* argv[])
{
  Package package;
  
  for (int i = 1; i < argc; ++i)
    {
      package.Clear();
      package.ParsePackage (argv[i]);

      unsigned int no_downloads = package.download.download_infos.size();

      for (unsigned int dl=0; dl < no_downloads; dl++) {
	DownloadInfo& info=package.download.download_infos[dl];

	// TODO: Choose type out of mirror and nodist. Not yet
	// used in tree - and imperfectly implemented in rock ...
	std::string store_url = "download/";
	store_url += "mirror/";
	store_url += info.file[0];
	store_url += + "/";
	store_url += info.file;
	
	if (info.protocol == "http" || info.protocol == "ftp") {
	  std::cerr << "Would download: " << info.down_url
		    << " -> " << store_url << std::endl;
	}
	else
	  std::cerr << "Error: protocol '" << info.protocol
		    << "' not yet implemented" << std::endl;
      }
    }
}
