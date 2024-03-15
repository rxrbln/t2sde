/*
 * Copyright (C) 2009 - 2010 René Rebe, ExactCODE GmbH, Germany.
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 2. A copy of the GNU General
 * Public License can be found in the file LICENSE.
 * 
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANT-
 * ABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
 * Public License for more details.
 *
 * Alternatively, commercial licensing options are available from the
 * copyright holder ExactCODE GmbH Germany.
 */

#ifndef UTILITY__FDSTREAM_HH__
#define UTILITY__FDSTREAM_HH__

#include <unistd.h>

#include <sys/types.h>
#include <sys/wait.h>

#include <stdarg.h>

#include <iostream>

namespace Utility {

class fdbuf : public std::streambuf
{
protected:
  int fd;

  /* output */
  virtual int_type overflow(int_type c) {
	if (c != EOF) {
		char cc = c;
		if (write(fd, &cc, 1) != 1)
			return EOF;
	}
	else {
		return EOF;
	}
	return c;
  }
  virtual std::streamsize xsputn(const char* s, std::streamsize num) {
	return write(fd, s, num);
  }

  /* input */
  char buffer[2];
  virtual int_type underflow() {
	if (gptr() < egptr())
		return *gptr();

	int numPutback = gptr() - eback();
	if (numPutback > 1)
		numPutback = 1;

	buffer[0] = buffer[1];

	int num = read(fd, &buffer[1], 1);
	if (num <= 0)
		return EOF;

	setg(buffer + 1 - numPutback, buffer + 1, buffer + 1 + num);
	return *gptr();
  }

public:
  fdbuf(int fd)
    : fd(fd)
  {
    setg(buffer+1, buffer+1, buffer+1);
  }

  ~fdbuf() {
    close(fd);
  }
};

class fdostream : public std::ostream
{
public:
  fdostream(int fd)
  : std::ostream(&buf), buf(fd) {
  }

protected:
  fdbuf buf;
};

class fdistream : public std::istream
{
public:
  fdistream(int fd)
  : std::istream(&buf), buf(fd) {
  }

protected:
  fdbuf buf;
};


class fdstream : public std::iostream
{
public:
  fdstream(int fd)
  : std::iostream(&buf), buf(fd) {
  }

protected:
  fdbuf buf;
};

}

#endif
