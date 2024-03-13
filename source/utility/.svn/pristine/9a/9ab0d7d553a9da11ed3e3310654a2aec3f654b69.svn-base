
#ifndef UTILITY__PSTREAM_HH__
#define UTILITY__PSTREAM_HH__

#include <unistd.h>
#include <signal.h> // kill

#include <sys/types.h>
#include <sys/wait.h>

#include <stdarg.h>

#include <iostream>

namespace Utility {

class processbuf : public std::streambuf
{
protected:

  int pid;
  int sink[2];
  int source[2];

  /* output */
  virtual int_type overflow (int_type c) {
	if (c != EOF) {
		char cc = c;
		if (write (sink[1], &cc, 1) != 1)
			return EOF;
	}
	else {
		close_sink();
		return EOF;
	}
	return c;
  }
  virtual std::streamsize xsputn (const char* s, std::streamsize num) {
	return write (sink[1], s, num);
  }

  /* input */
  char buffer [2];
  virtual int_type underflow () {
	if (gptr() < egptr())
		return *gptr();

	int numPutback = gptr() - eback();
	if (numPutback > 1)
		numPutback = 1;

	buffer[0] = buffer[1];

	int num = read (source[0], &buffer[1], 1);
	if (num <= 0)
		return EOF;

	setg (buffer + 1 - numPutback, buffer + 1, buffer + 1 + num);
	return *gptr();
  }

public:
  processbuf () {
    setg (buffer+1, buffer+1, buffer+1);
  }

  processbuf (const char* file, char* const argv[]) {
    setg (buffer+1, buffer+1, buffer+1);
    exec (file, argv);
  }

  ~processbuf () {
    close(source[0]); close(sink[1]);
    waitpid(pid, NULL, 0);
  }
  
  void exec (const char* file, const char* arg, va_list ap) {
    const char* args[10];
    // convert va_list into static char* array -sigh
    int i = 0;
    args[i++] = arg;
    for (; i < ((int) sizeof(args))-1; ++i) {
      const char* s = va_arg(ap, const char*);
      if (s != NULL) {
	// std::cout << "Got: " << s << std::endl;
	args[i] = s;
      }
      else
	break;
    }
    args[i] = NULL;
    exec (file, (char* const*)args);
  }

  void exec (const char* file, char* const argv[]) {
    pipe (sink);
    pipe (source);
    if ((pid = fork()) == 0) {
      dup2(sink[0],0); close(sink[0]); close(sink[1]);
      dup2(source[1],1); close(source[0]); close(source[1]);
      execvp(file, argv);
      perror(file);
      _exit(1);
    }
    close(source[1]); close(sink[0]);
  }
  
  void close_sink () {
    close(sink[1]);
  }

  void terminate (int signal) {
    close(source[0]);
    close(sink[1]);
    kill(pid, signal);
  }
  
};

class postream : public std::ostream
{
public:
  postream (const char* file, char* const argv[])
  : std::ostream(&buf), buf(file, argv){
  }

  postream (const char* file, const char* args, ...)
    : std::ostream(&buf) {
    va_list ap, aq;
    va_start (ap, args);
    va_copy (aq, ap);
    
    buf.exec (file, args, ap);
    va_end (aq);
    va_end (ap);
  }

  void terminate (int signal=SIGTERM) {
    buf.terminate (signal);
  }

protected:
  processbuf buf;
};

class pistream : public std::istream
{
public:
  pistream (const char* file, char* const argv[])
  : std::istream(&buf), buf(file, argv) {
  }

  pistream (const char* file, const char* args, ...)
    : std::istream(&buf) {
    va_list ap, aq;
    va_start (ap, args);
    va_copy (aq, ap);
    
    buf.exec (file, args, ap);
    va_end (aq);
    va_end (ap);
  }

  pistream (...)
    : std::istream(&buf) {
    //    buf(", "");
  }

  void terminate (int signal=SIGTERM) {
    buf.terminate (signal);
  }

protected:
  processbuf buf;
};


class pstream : public std::iostream
{
public:
  pstream (const char* file, char* const argv[])
    : std::iostream(&buf), buf(file, argv) {
  }

  pstream (const char* file, const char* args, ...)
    : std::iostream(&buf) {
    va_list ap, aq;
    va_start (ap, args);
    va_copy (aq, ap);
    
    buf.exec (file, args, ap);
    va_end (aq);
    va_end (ap);
  }

  void close_sink () {
    buf.close_sink ();
  }

  void terminate (int signal=SIGTERM) {
    buf.terminate (signal);
  }

protected:
  processbuf buf;
};

}

#endif
