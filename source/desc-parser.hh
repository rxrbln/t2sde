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
    std::string::size_type line_start = 0;
    std::string::size_type line_end;
    do {
      line_end = value.find('\n', line_start);
      std::string line = value.substr(line_start, line_end-line_start);
      ParseLine (line);
      line_start = line_end+1;
    } while (line_end != std::string::npos && line_end < value.length()-1); 

    return true;
  }

  virtual void ClearImpl ()
  {
    download_infos.clear ();
  }

  std::vector<DownloadInfo> download_infos;

private:
  bool ParseLine (const std::string& line)
  { // Todo: Error evaluation !
    DownloadInfo info;
    std::stringstream sstr(line);
    sstr >> info.chksum;
    sstr >> info.file;
    sstr >> info.url;

    if (info.url[0] == '!') { // overwriting filename
      info.url.erase(0,1);
      info.down_url = info.url;
      std::string::size_type url_end = info.url.rfind('/');
      info.url = info.url.substr(0,url_end);
    } else
      info.down_url = info.url+info.file;

    std::string::size_type protocol_end = info.url.find(':');
    info.protocol = info.url.substr(0, protocol_end);

    download_infos.push_back(info);
    return true;
  }
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
