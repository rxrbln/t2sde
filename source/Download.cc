
#include <ostream>

#include "desc-parser.hh"

int main (int argc, char* argv[])
{
  Package package;
  
  for (int i = 1; i < argc; ++i)
    {
      package.Clear();
      package.Parse (argv[i]);
      
      std::cout << package.download.value << std::endl;
    }
}
