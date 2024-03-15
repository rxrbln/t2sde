
#include <iostream>
#include "pstream.hh"

using namespace Utility;

int main ()
{
  pistream cat ("cat", (char*[]){"cat", "/proc/cpuinfo", 0} );

  std::cout << cat.rdbuf();
  
  pstream sed ("sed", "sed", "s/World/C++/g", NULL);
  
  sed << "Hello World!" << std::endl;
  sed.close_sink();
  
  std::cout << sed.rdbuf();
}
