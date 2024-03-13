
/* Copyright 2005 - 2007 René Rebe - ExactCODE GmbH */

#ifndef UTILITY__GLOB_HH__
#define UTILITY__GLOB_HH__

#include <glob.h>
#include <string>

namespace Utility
{

/* very lightweight glob wrapper ... */
class Glob
{
 public:

  typedef char** iterator;

  Glob (const std::string& pattern, int flags = 0) {
    glob (pattern.c_str(), flags, NULL, &g);
  }
  ~Glob () {
    globfree (&g);
  }

  iterator begin() {
    return g.gl_pathv;
  }

  iterator end() {
    return g.gl_pathv + g.gl_pathc;
  }
  
  operator void*() {
    return g.gl_pathc == 0 ? 0 : this;
  }
  
  bool operator!() const {
    return g.gl_pathc == 0;
  }
  
  private:
    glob_t g;
};

}

#endif
