
#include "tag-parser.hh"

// some inteligent Version information class, that contains
// some logic to compare version numbers, including -beta and
// -alpha suffixes

// TODO: IMHO better tat bookkeeping ... -ReneR
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
      
      download("D","DOWN","DOWNLOAD"),
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
  
  bool ParsePakage(const std::string& file)
  {
    return Parse(file);
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
  
  Tag download;
  Tag cv_url;
  
  Tag sourcepackage;
  Tag conf;
};
