#include "tag-parser.hh"
#include "utility/src/File.cc"
#include <map>
#include <sstream>

// todo: const correctness

class PkgNode
{
public:
  typedef std::vector <std::string> DependencyVector;
  typedef DependencyVector::iterator iterator;

  PkgNode (std::string i_name)
  {
    name = i_name;
    priority = -1;
  }

  iterator Begin () {return depend.begin();}
  iterator End () {return depend.end();}

  void AddDependency (const std::string& dep) {depend.push_back(std::string(dep));}

  const std::string& Name () {return name;}

private:
  friend class PkgGraph;

  std::string name;
  DependencyVector depend;
  int priority; // -1 = not evaluated yet; -2 = in evaluation;
};

class PkgGraph : public std::map <std::string, PkgNode*>
{
public: // TODO: duplication checking !!
  void AddPkg (PkgNode* pkg) { (*this)[pkg-> Name()] = pkg; }

  int GetPriority (const std::string& pkgname)
  {
    iterator pi = find(pkgname);
    if (pi == end()) {
      std::cerr << "Warning: could not find package '" << pkgname << "'" << std::endl;
      return 0;
    }
    
    PkgNode& node = *(pi -> second);
    if (node.priority == -2) {
      std::cerr << "Warning: circular dependency detected involving package '"
		<< pkgname << "'" << std::endl;
       node.priority = 0;
    } else if (node.priority == -1) {
      int new_priority = 0;
      node.priority = -2;
      for (PkgNode::iterator i = node.Begin(); i != node.End(); i++)
	new_priority = std::max (new_priority, GetPriority(*i));
      node.priority = new_priority + 1;
    }
    return node.priority;
  }

} pkg_graph;


class CacheFile : public TagParser
{
public:

  CacheFile ()
    : copyright("COPY","",""),
     
      timestamp("TIMESTAMP","",""),
      config_id("CONFIG-ID","",""),
      version("ROCKVER","",""),

      logs("LOGS","",""),

      buildtime("BUILDTIME","",""),
      size("SIZE","",""),

      dep("DEP","",""),

      error0("0-ERROR","",""),
      error1("1-ERROR","",""),
      error2("2-ERROR","",""),
      error3("3-ERROR","",""),
      error4("4-ERROR","",""),
      error5("5-ERROR","",""),
      error6("6-ERROR","",""),
      error7("7-ERROR","",""),
      error8("8-ERROR","",""),
      error9("9-ERROR","","")
  {
    tags.push_back(&copyright);
    tags.push_back(&timestamp);
    tags.push_back(&config_id);
    tags.push_back(&version);
    tags.push_back(&logs);
    tags.push_back(&buildtime);
    tags.push_back(&size);
    tags.push_back(&dep);

    tags.push_back(&error0);
    tags.push_back(&error1);
    tags.push_back(&error2);
    tags.push_back(&error3);
    tags.push_back(&error4);
    tags.push_back(&error5);
    tags.push_back(&error6);
    tags.push_back(&error7);
    tags.push_back(&error8);
    tags.push_back(&error9);
  }

  PkgNode* DepsFromFile(const std::string& pkgname, const std::string& file)
  {
    Clear ();
    if (!Parse (file))
      std::cerr << "warning: there were errors in the cache file of package '"
      		<< pkgname << "'" << std::endl;

    PkgNode* ret = new PkgNode (pkgname);

    // split dep tag value into single tokens and add into PkgNode's Dependency vector.
    std::stringstream stream(dep.value);
    while (stream) {
      std::string s = "";
      stream >> s;
      if (s != "")
	ret -> AddDependency(s);
    }

    return ret;
  }

  Tag copyright;

  Tag timestamp;
  Tag config_id;
  Tag version;

  Tag logs;

  Tag buildtime;
  Tag size;

  Tag dep;

  // Todo: replace those
  Tag error0;
  Tag error1;
  Tag error2;
  Tag error3;
  Tag error4;
  Tag error5;
  Tag error6;
  Tag error7;
  Tag error8;
  Tag error9;

} cache_file; 



std::string PkgName (const std::string& file)
{
  //std::cout << Utility::File(file).Basename() << std::endl;
  return Utility::File(file).Basename();
}


int main (int argc, char** argv)
{
  argv ++;
  while (*argv) {
    pkg_graph.AddPkg(
	  cache_file.DepsFromFile(
		 PkgName(*argv), std::string(*argv)));
    argv ++;
  }

  std::cout << pkg_graph.GetPriority ("flex") << std::endl;
}
