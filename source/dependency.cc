#include "tag-parser.hh"
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
  }

  iterator Begin () {return depend.begin();}
  iterator End () {return depend.end();}

  void AddDependency (const std::string& dep) {depend.push_back(std::string(dep));}

  const std::string& Name () {return name;}

private:
  std::string name;
  DependencyVector depend;
};

class PkgGraph : public std::map <std::string, PkgNode*>
{
public: // TODO: duplication checking !!
  void AddPkg (PkgNode* pkg) { (*this)[pkg-> Name()] = pkg; }
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

      dep("DEP","","")
  {
    tags.push_back(&copyright);
    tags.push_back(&timestamp);
    tags.push_back(&config_id);
    tags.push_back(&version);
    tags.push_back(&logs);
    tags.push_back(&buildtime);
    tags.push_back(&size);
    tags.push_back(&dep);
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
} cache_file; 



int main (int argc, char** argv)
{
  argv ++;
  while (*argv) {
    cache_file.DepsFromFile("Hallo", std::string(*argv));
    argv ++;
  }
}
