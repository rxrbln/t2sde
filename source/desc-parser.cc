
#include <vector>
#include <iostream>
#include <fstream>

// some inteligent Version information cless, that contains
// some logic to compare version numbers, including -beta and
// -alpha suffixes

class DescTag {
public:
  
  DescTag(const std::string& i_short_name,
	  const std::string& i_name,
	  const std::string& i_long_name)
    : short_name(i_short_name), name(i_name),
      long_name(i_long_name)
  {
  };
  
  virtual ~DescTag(){};
  
  virtual std::ostream& Read(std::istream& is)
  {
  }
  virtual std::ostream& Write(std::ostream& os)
  {
  }
  
  std::string short_name;
  std::string name;
  std::string long_name;
  
  std::string value;
};


// TODO: IMHO better tat bookkeeping ... -ReneR
class Package
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
  }
  
  ~Package()
  {}
  
  bool Parse(const std::string& file)
  {
    int error = 0;
    
    std::vector<DescTag*> tags;
    
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
    
    // parse
    std::fstream desc_file(file.c_str());
    
    std::string line;
    std::string tag, value;
    for (int linenr = 0; desc_file; ++linenr) {
      std::getline(desc_file, line);
      
      if (line.size() == 0)
	continue;
      
      // skip comments (maybe we also need to compress
      // whitespaces? -ReneR
      if (line[0] == '#' || line[0] == ' ')
	continue;
      
      if (line.size() < 3) {
	++error;
	std::cout << "Error: Only garbage found in line "
		  << linenr << ":" << std::endl
		  << "  " << line << std::endl;
      }
      
      std::string::size_type idx = line.find(' ');
      if (idx == std::string::npos)
	idx = line.size();
      
      if (line[0] != '[' || line[idx - 1] != ']') {
	++error;
	std::cout << "Error: No tag found in line "
		  << linenr << ":" << std::endl
		  << "  " << line << std::endl;
	continue;
      }
      
      tag.erase();
      tag.append(line, 1, idx - 2);
      value.erase();
      value.append(line, idx, std::string::npos);
      
      // search thru "registered" tags
      bool tag_found = false;
      for (int i = 0; i < tags.size(); ++i) {
	if (tag == tags[i]->short_name ||
	    tag == tags[i]->long_name ||
	    tag == tags[i]->name)
	  {
	    tags[i]->value.append (value + '\n');
	    tag_found = true;
	    break;
	  }
      }
      
      if (!tag_found) {
	++error;
	std::cout << line << std::endl;
	std::cout << "Error: Unknown tag: " << tag << " in line "
		  << linenr << std::endl;
      }
    }
    return error == 0;
  }
  
  DescTag copyright;

  DescTag title;
  DescTag text;
  DescTag url;
  
  DescTag author;
  DescTag maintainer;
  
  DescTag category;
  DescTag flags;
  DescTag arch;
  DescTag dependency;
  
  DescTag license;
  DescTag status;
  DescTag version;
  DescTag priority;
  
  DescTag download;
  DescTag cv_url;
  
  DescTag sourcepackage;
  DescTag conf;
};

int main (int argc, char* argv[])
{
  Package p;
  
  if (argc > 1)
    if (!p.Parse (argv[1]))
      return 1;
  
  return 0;
}
