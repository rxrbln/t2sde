
#include <vector>
#include <iostream>
#include <sstream>

#include "DirIterator.hh"
#include "Threads.hh"

Utility::Threads::Mutex big_lock;

class Scan : public Utility::Threads::Thread
{
private:
  std::string s;
public:
  Scan (const std::string i_s) {
    // std::cout << "Creating thread for " << i_s << std::endl;
    s = i_s;
    Create (0);
  }
  
protected:
  
  void* main (void*)
  {
    Utility::DirList dir (s);
    Utility::DirList::Iterator it, it_end;
    std::vector<Scan*> threads;
    
    it = dir.Begin ();
    it_end = dir.End ();
    
    while  (it != it_end) {
      big_lock.Lock();
      std::cout << s + '/' + *it << std::endl;
      big_lock.Unlock();
      
      if (it.Type().IsDirectory()) {
	Scan* new_thread = new Scan (s + '/' + *it);
	threads.push_back(new_thread);
      }
      ++ it;
    }
    
    // join all threads ...
    while (threads.size()>0) {
      Scan* thread = threads.back();
      // std::cout << "Waiting for thread " << thread->s << std::endl;
      thread->Join();
      delete thread;
      threads.pop_back();
    }
    
    return 0;
  }
};

int main (int argc, char* argv[])
{
  std::string start ("/home/rene");
  if (argc > 1)
    start = argv[1];
  
  Scan s (start);
  s.Join();
  //std::cout << "EOP" << std::endl;
}
