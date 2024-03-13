
#include <iostream>
#include <sstream>

#include <deque>

#include "DirIterator.hh"

// !sorted might be faster but less sorted ...
const bool sorted = true;

std::deque<std::string> todo_queue;

void scan (const std::string s)
{
  Utility::DirList dir (s);
  Utility::DirList::Iterator it (dir.Begin());
  Utility::DirList::Iterator it_end (dir.End ());
  
  while  (it != it_end) {
    std::cout << s + '/' + *it << std::endl;
    if (it.Type().IsDirectory()) {
      if (sorted)
        scan (s + '/' + *it);
      else
        todo_queue.push_back (s + '/' + *it);
    }
    ++ it;
  }

  if (!sorted)
    while (todo_queue.size() > 0) {
      std::string ts (todo_queue.front());
      todo_queue.pop_front();
      scan(ts);
    }
}

int main (int argc, char* argv[])
{
  std::string start ("/home/rene");
  if (argc > 1)
    start = argv[1];
  
  scan (start);
}
