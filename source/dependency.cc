#include "tag-parser.hh"
#include "utility/src/File.cc"
#include <map>
#include <sstream>
#include <algorithm>

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

  int Priority () {return priority;}

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

  typedef std::map <std::string, PkgNode*>::iterator iterator;

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
  return Utility::File(file).BasenameWOExtension();
}

class PriorityCmp
{
public:
  bool operator() (PkgNode* a, PkgNode* b)
  {
    return a->Priority() < b->Priority();
  }
};

class DownArrow
{
public:
  DownArrow (unsigned int pkg_priority)
  {
    start = pkg_priority;
    end = pkg_priority; 
  }

  void SetNeed (unsigned int by_priority)
  {
    end = std::max(end, by_priority);
  }

  // returns true iff a and this arrow can be drawn in the same column
  bool Compatible (const DownArrow& a)
  {
    return (a.start > end || a.end < start);
  }

  unsigned int start;
  unsigned int end;
  unsigned int h_pos;
};

std::map <std::string, DownArrow*> down_arrows;
typedef std::map <std::string, DownArrow*>::iterator arrow_iterator;

void InsertAt(std::string& s, unsigned int char_pos, char c)
{
  while (s.length() <= char_pos)
    s += " ";
  s[char_pos] = c;
}

std::string Template (unsigned int v_pos)
{
  arrow_iterator arr_end = down_arrows.end ();
  std::string ret = "";

  for (arrow_iterator i = down_arrows.begin(); i != arr_end; i++) {
    if (i -> second -> start <= v_pos && i -> second -> end > v_pos)
      InsertAt(ret, 2*(i -> second -> h_pos), '|');
  }

  return ret;
}

std::string HRef (PkgNode& node, unsigned int v_pos)
{
  std::string tmpl = Template(v_pos);
  arrow_iterator arr_end = down_arrows.end ();
  
  unsigned int h_min = ((unsigned int) ((int) -1));

  // comparism (1) is a workaround for those cross references

  for (PkgNode::iterator dep_on = node.Begin(); dep_on != node.End(); dep_on++) {
    arrow_iterator arrow = down_arrows.find(*dep_on);
    if (arrow != arr_end && arrow -> second -> start < v_pos /* (1) */) {
      h_min = std::min (h_min, arrow -> second -> h_pos);
      InsertAt(tmpl, 2*(arrow -> second -> h_pos), '+');
    }
  }

  arrow_iterator arrow = down_arrows.find(node.Name());
  if (arrow != arr_end) {
    h_min = std::min (h_min, arrow -> second -> h_pos);
    InsertAt(tmpl, 2*(arrow -> second -> h_pos), 'v');
  }

  for (unsigned int i = 2*h_min; i < tmpl.length(); i++)
    if (tmpl[i] != 'v' && tmpl[i] != '+')
      tmpl[i]='-';

  return tmpl;
}


void PrintGraph ()
{
  std::vector <PkgNode*> needed;

  for (PkgGraph::iterator i = pkg_graph.begin(); i != pkg_graph.end(); i++) {
    if (i -> second -> Priority () >= 0)
      needed.push_back (i -> second);
  }

  // sort after priority
  std::sort (needed.begin(), needed.end(), PriorityCmp ());

  arrow_iterator arr_end = down_arrows.end ();



  // compute DownArrow lengh
  for (unsigned int i = 0; i < needed.size(); i++) {
    PkgNode& current = *(needed[i]);
    down_arrows[current.Name()] = new DownArrow (i);
    for (PkgNode::iterator dep_on = current.Begin(); dep_on != current.End(); dep_on++) {
      arrow_iterator arrow = down_arrows.find(*dep_on);
      if (arrow != arr_end)
	arrow -> second -> SetNeed(i);
    }
  }

  // greedyly arrange DownArrows horizontaly
  for (unsigned int i = 0; i < needed.size(); i++) {
    arrow_iterator cur_assign = down_arrows.find(needed[i] -> Name());

    unsigned int h_pos = 0;
    bool pos_found;  

    do {
      pos_found = true;

      for (unsigned int j = 0; j < i ; j++) {
	arrow_iterator assigned = down_arrows.find(needed[j] -> Name());
	if (assigned -> second -> h_pos == h_pos)
	  if (!(assigned -> second -> Compatible(*(cur_assign -> second))))
	    pos_found = false;
      }

      if (pos_found)
	cur_assign -> second -> h_pos = h_pos;
      else
	h_pos++;
    } while (!pos_found);

  }

  // Print the graph
  for (unsigned int i = 0; i < needed.size(); i++) {
    std::cout << HRef (*(needed[i]),i) << "---" << needed[i] -> Name() << std::endl
	      << Template(i) << std::endl; 
  }
}



int main (int argc, char** argv)
{
  if (argc < 3) {
    std::cerr << argv[0] << " <pkgs> <cachefile>+" << std::endl;
    exit (-1);
  }

  std::string package(argv[1]);
  argv += 2;
  while (*argv) {
    pkg_graph.AddPkg(
	  cache_file.DepsFromFile(
		 PkgName(*argv), std::string(*argv)));
    argv ++;
  }

  pkg_graph.GetPriority (package);

  PrintGraph();
}
