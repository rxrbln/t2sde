
#include <ostream>

#include "desc-parser.hh"
#include "Curl.hh"
#include "ctype.h"

#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <glob.h>

std::vector <std::string> suffixes;

// maybe inherit std::string? -ReneR
class Version
{
public:
  
  Version () {
    version = "";
  };
  
  Version (const std::string& i_version) {
    version = i_version;
  }
  
  void ExtractFromFilename (const std::string& filename) {
    for (std::string::size_type i = 0; i < filename.size(); ++i)
      if (isdigit(filename[i])) {
	version = filename.substr(i);
	std::cout << "Vesion set to: " << version << std::endl;
	return;
      }
    version.clear();
    std::cout << "No version extracted!" << std::endl;
  }
  
  std::string::size_type size() const {
    return version.size();
  }

  char operator[](std::string::size_type i) const {
    return version[i];
  }
  
  int compare (const Version& a, const Version& b) const
  {
    class subversion {
    public:
      
      std::string::size_type read (const std::string& s,
				   std::string::size_type i)
      {
	val.clear();;
	//std::cout << i << ": " << s[i] << std::endl;
	for (;i < s.size() && (isdigit(s[i]) || isalpha(s[i])); ++i) {
	  val += s[i];
	  // std::cout << "  " << val << std::endl;
	}
	return ++i;
      }

      std::string::size_type size() const {
	return val.size();
      }
      
      char operator[](std::string::size_type i) const {
	return val[i];
      }
      
      bool empty() const {
	return val.empty();
      }
      
      const std::string& str () const {
	return val;
      }
      
      bool same_cclass (char a, char b) const {
	// I'm sure this could be done more elegant
	return ( (isalpha(a) && isalpha(b)) ||
		 (isdigit(a) && isdigit(b)) );
      }
      
      bool operator< (const subversion& other) const {
	// catch range exceptions ;-)
	try {
	  if (!same_cclass(val[0], other.val[0]))
	    return (isalpha(val[0]));
	}
	catch (...) {
	}
	return val < other.val;
      }

      bool operator> (const subversion& other) const {
	// catch range exceptions ;-)
	try {
	  if (!same_cclass(val[0], other.val[0]))
	    return (isalpha(other.val[0]));
	}
	catch (...) {
	}
	return val > other.val;
      }
      
    private:
      std::string val;
    };
  
    std::cout << "Comparing: " << a.str() << " with " << b.str() << std::endl;
    
    std::string::size_type i, j;
    subversion subv_a, subv_b;
    for (i = j = 0; i < a.size() && j < b.size();) {
      
      i = subv_a.read(a.str(), i);
      j = subv_b.read(b.str(), j);
      
      std::cout << subv_a.str() << " vs " << subv_b.str() << ": ";
      
      if (subv_a < subv_b) {
	std::cout << "... <" << std::endl;
	return -1;
      }
      if (subv_a > subv_b) {
	std::cout << "... >" << std::endl;
	return 1;
      }
      
      std::cout << "=,  " << std::endl;
    }

    i = subv_a.read(a.str(), i);
    j = subv_b.read(b.str(), j);
    
    std::cout << "Final: " << subv_a.str() << " vs " << subv_b.str() << ": ";
    
    if (!subv_a.empty())
      {
	if (isdigit(subv_a[0])) {
	  std::cout << "... >" << std::endl;
	  return 1;
	}
	else {
	  std::cout << "... <" << std::endl;
	  return -1;
	}
      }
    
    if (!subv_b.empty())
      {
	if (isdigit(subv_a[0])) {
	  std::cout << "... <" << std::endl;
	  return 1;
	}
	else {
	  std::cout << "... >" << std::endl;
	  return -1;
	}
      }
    
    std::cout << "... =" << std::endl;
    return 0;
  }

  bool operator< (const Version& b) const
  {
    return compare(*this, b) == -1;
  }
  
  bool operator> (const Version& b) const
  {
    return compare(*this, b) == 1;
  }
  
  const std::string& str () const {
    return version;
  }
  
private:
  
  std::string version;
  
};

void GenList (std::string file, std::ifstream& s, bool quote_mode) {
  // search for a matching extension
  std::string templ = file;
  std::string suffix = "";

  for (unsigned int i = 0; i < suffixes.size(); ++i) {
    std::string& test = suffixes[i];
    std::string::size_type s_pos = templ.rfind(test);
    if (s_pos != std::string::npos) {
      suffix = test;
      templ = templ.substr(0, s_pos);
      break;
    }
  }

  Version version;
  std::vector <Version> versions;
  std::vector <Version> newer_versions;

  version.ExtractFromFilename (templ);

  std::string prefix;

  std::string::size_type idx = templ.rfind(version.str());
  if (idx == std::string::npos)
    prefix = templ;
  else
    prefix = templ.substr(0,idx);
  
  if (quote_mode) {
    prefix = "\"" + prefix;
    suffix += "\"";
  }

  std::cout << file << "(" << version.str()
	    << ") ---> " << prefix << "???" << suffix << std::endl;

  std::string token;
  while (!s.eof()) {
    s >> token;
    
    idx = token.find(prefix);
    
    if (idx != std::string::npos) {
      //      std::cout << token << std::endl;
      std::string::size_type idx2;
      
      if (suffix.length() > 0)
	idx2 = token.find(suffix, idx+1);
      else {
	idx2 = token.find(' ', idx+1);
	if (idx2 == std::string::npos)
	  idx2 = token.length() - 1;
      }

      if (idx2 != std::string::npos) {
	std::string::size_type begin = (quote_mode) ? idx+1 : idx;
	std::string::size_type length = (idx2-idx); //+suffix.length();
	if (quote_mode)
	  length -= 1;

	std::string matched = token.substr(begin, length);
	Version v;
	v.ExtractFromFilename (matched);
	
	versions.push_back(v);
      }

    }
  }
  
  for (unsigned int i = 0; i < versions.size(); ++i) {
    int sign = version.compare(versions[i],version);
    
    std::cout << "[MATCH] (" << versions[i].str() << ")";
    
    switch (sign) {
    case 0:
      std::cout << " [=]" << std::endl;
      break;
    case 1:
      std::cout << " [+]" << std::endl;
      newer_versions.push_back(versions[i]);
      break;
    case -1:
      std::cout << " [-]" << std::endl;
      break;
    }
  
  }
  
  std::cout << "-----------------------" << std::endl;

  std::sort(newer_versions.begin(), newer_versions.end());
  if (newer_versions.size() > 0)
    std::cout << "XXX " << newer_versions[0].str() << std::endl;
  
  std::cout << "-----------------------" << std::endl;
}

int main (int argc, char* argv[])
{
  suffixes.push_back(".tar.bz2");
  suffixes.push_back(".tar.gz");
  suffixes.push_back(".tbz2");
  suffixes.push_back(".tgz");
  suffixes.push_back(".bz2");
  suffixes.push_back(".gz");
  
  std::vector<Version> versions;
  versions.push_back(Version("1.2.2"));
  versions.push_back(Version("1.2.4"));
  versions.push_back(Version("1.2.3"));
  versions.push_back(Version("1.2.3b"));
  versions.push_back(Version("1.2.3a"));
  versions.push_back(Version("1.2.3-pre9"));
  versions.push_back(Version("1.2.3-pre12"));
  versions.push_back(Version("1.2.3-beta"));
  versions.push_back(Version("1.2.3-rc2"));
  versions.push_back(Version("1.2.3-alpha"));
  versions.push_back(Version("1.2.3-rc1"));
  versions.push_back(Version("1.2.3.1"));

  Package package;

  std::cout << "-----------------------" << std::endl;

  std::sort(versions.begin(), versions.end());

  for (unsigned int i = 0; i < versions.size(); ++i)
    std::cout << "  " << versions[i].str() << std::endl;
  
  std::cout << "-----------------------" << std::endl;

  for (int i = 1; i < argc; ++i)
    {
      package.Clear();

      // check if package name or path is given
      std::string fname = argv[i];
      struct stat statbuf;
      if (stat(fname.c_str(), &statbuf)) {
	fname = "package/*/" + fname + "/" + fname + ".desc";
	// std::cout << "Checking " << fname << std::endl;

	glob_t globbuf;
	if (glob(fname.c_str(), GLOB_ERR, NULL, &globbuf) == 0) {
	  fname = globbuf.gl_pathv[0];
	  // std::cout << "Found " << fname << std::endl;
	}
	globfree(&globbuf);
      }

      // parse package ...
      package.ParsePackage (fname);

      unsigned int no_downloads = package.download.download_infos.size();

      CurlWrapper dl;
      dl.SetConnectTimeout(15);
      dl.SetMaxTime(30);

      for (unsigned int dln = 0; dln < no_downloads; ++dln)
	{
	  DownloadInfo& info = package.download.download_infos[dln];
	  
	  try {
	    if (info.protocol == "http" || info.protocol == "ftp") {
	      std::cout << "trying to download listing of " << info.url << std::endl;
	      
	      dl.Download(info.url, 0, 200000);
	     
	      std::ifstream* s = dl.OpenFile();
	      GenList(info.file, *s, info.protocol == "http");
	      s -> close();
	    }
	  }
	  catch (TimeoutException e) {
	    std::cout << "Operation timeout" << std::endl;
	  }
	  catch (UnsupportedProtocolException e) {
	    std::cout << "Unsupported protocol : " << info.protocol << std::endl;
	  }
	  catch (MalformedUrlException e) {
	    std::cout << "Malformed URL or invalid URL options" << info.url << std::endl;
	  }
	  catch (ConnectErrorException e) {
	    std::cout << "Could not connect to host" << std::endl;
	  }
	  catch (AccessDeniedException e) {
	    std::cout << "Access denied or invalid user/pass" << std::endl;
	  }
	  catch (DoesNotExistException e) {
	    std::cout << "File does not exist" << std::endl;
	  }
	  catch (CurlException e) {
	    std::cout << "operation canceled due to errors executing '"
		      << dl.GetCommand() << "'" << std::endl;
	  }
	}
      dl.RemoveFile();
    }
}
