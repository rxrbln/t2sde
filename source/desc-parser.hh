#include "tag-parser.hh"
#include <sstream>

// some inteligent Version information class, that contains
// some logic to compare version numbers, including -beta and
// -alpha suffixes

class DownloadInfo
{
public:
  std::string chksum;
  std::string file;
  std::string url;
  std::string down_url;
  std::string protocol;
};

class DownloadTag : public Tag
{
public:
  DownloadTag () : Tag ("D","DOWN","DOWNLOAD") {}

  bool Parse ()
  {
    std::stringstream sstr (value);

    // TODO: clean this mess up and check for errors !!

    while (sstr) {
      DownloadInfo info;
      sstr >> info.chksum >> info.file;
      if (!sstr) // work around for trailing newlines
	continue;
      std::getline(sstr, info.url);
	
      // url contains at least one leading ' ' ...
      info.url.erase(0, 1);
      bool overwrite_url = info.url[0] == '!';
      if (overwrite_url)
	info.url.erase(0, 1);
	
      std::string::size_type idx = info.url.find(':');
      if (idx == std::string::npos)
	info.protocol.clear();
      else
	info.protocol = info.url.substr(0, idx);
      if (info.protocol.size() > 0 && info.protocol[0] == '!')
	  info.protocol.erase(0, 1);
	
	if (overwrite_url)
	  info.down_url = info.url;
	else
	  info.down_url = info.url + info.file;
	download_infos.push_back(info);
      }

    return true;
  }

  std::vector<DownloadInfo> download_infos;
};


// TODO: IMHO better tag bookkeeping ... -ReneR
class Package : public TagParser
{
public:
  Package()
    : copyright("COPY","",""),
      
      title("I","","INFO"),
      text("T","","TEXT"),
      url("U","","URL"),
      
      author("A","AUTH","AUTHOR"),
      maintainer("M","","MAINTAINER"),
      category("C","","CATEGORY"),
      flags("F","","FLAGS"),
      arch("R","ARCH","ARCHITECTUR"),
      dependency("E","DEP","DEPENDENCY"),
      
      license("L","","LICENCE"),
      status("S","","STATUS"),
      version("V","VER","VERSION"),
      priority("P","","PRIORITY"),
      
      download (),
      cv_url("","","CV-URL"),
      
      sourcepackage("SRC","","SRCPACKAGE"),
      conf("O","","CONF")
  {
    tags.push_back(&copyright);
    tags.push_back(&title);
    tags.push_back(&text);
    tags.push_back(&url);
    
    tags.push_back(&author);
    tags.push_back(&maintainer);
    
    tags.push_back(&category);
    tags.push_back(&flags);
    tags.push_back(&arch);
    tags.push_back(&dependency);
    
    tags.push_back(&license);
    tags.push_back(&status);
    tags.push_back(&version);
    tags.push_back(&priority);
    
    tags.push_back(&download);
    tags.push_back(&cv_url);
    tags.push_back(&sourcepackage);
    tags.push_back(&conf);
  }
  
  ~Package()
  {}
  
  bool ParsePackage(const std::string& file)
  {
    return Parse(file) && download.Parse();
  }
  
  Tag copyright;

  Tag title;
  Tag text;
  Tag url;
  
  Tag author;
  Tag maintainer;
  
  Tag category;
  Tag flags;
  Tag arch;
  Tag dependency;
  
  Tag license;
  Tag status;
  Tag version;
  Tag priority;
  
  DownloadTag download;
  Tag cv_url;
  
  Tag sourcepackage;
  Tag conf;
};
