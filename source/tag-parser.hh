#include <vector>
#include <iostream>
#include <fstream>


class Tag {
public:
  
  Tag(const std::string& i_short_name,
	  const std::string& i_name,
	  const std::string& i_long_name)
    : short_name(i_short_name), name(i_name),
      long_name(i_long_name)
  {
  };
  
  virtual ~Tag(){};
  
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


class TagParser
{
protected:
  TagParser () {}
  virtual ~TagParser () {}

  bool Parse(const std::string& file)
  {
    int error = 0;
    
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

  // derived class has to fill this vector
  std::vector<Tag*> tags;

};
