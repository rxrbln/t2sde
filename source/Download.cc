
#include <ostream>
#include <sstream>

#include <boost/regex.hpp>

#include "desc-parser.hh"

int main (int argc, char* argv[])
{
  Package package;
  
  for (int i = 1; i < argc; ++i)
    {
      package.Clear();
      package.Parse (argv[i]);
      std::stringstream sstr (package.download.value);
      
      std::cerr << package.download.value;
      
      std::string chksum, file, url, protocol;
      while (sstr) {
	sstr >> chksum >> file;
	if (!sstr) // work around for trailing newlines
	  continue;
	std::getline(sstr, url);
	
	// url contains at least one leading ' ' ...
	url.erase(0, 1);
	bool overwrite_url = url[0] == '!';
	if (overwrite_url)
	  url.erase(0, 1);
	
	std::string::size_type idx = url.find(':');
	if (idx == std::string::npos)
	  protocol.clear();
	else
	  protocol = url.substr(0, idx);
	if (protocol.size() > 0 && protocol[0] == '!')
	  protocol.erase(0, 1);
	
	std::string down_url;
	if (overwrite_url)
	  down_url = url;
	else
	  down_url = url + file;
	
	// TODO: Choose type out of mirror and nodist. Not yet
	// used in tree - and imperfectly implemented in rock ...
	std::string store_url = "download/";
	store_url += "mirror/";
	store_url += file[0];
	store_url += + "/";
	store_url += file;
	
	if (protocol == "http" || protocol == "ftp") {
	  std::cerr << "Would download: " << down_url
		    << " -> " << store_url << std::endl;
	}
	else
	  std::cerr << "Error: protocol '" << protocol
		    << "' not yet implemented" << std::endl;
      }
    }
}
