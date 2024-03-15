/*
 * Copyright (C) 2014 - 2020 René Rebe, ExactCODE GmbH Germany.
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

#ifndef LOWLEVEL__BITS_HH__
#define LOWLEVEL__BITS_HH__

#include <stdint.h>
#include <istream>
#include <algorithm>
#include <cstdio>

namespace Exact {

static const unsigned char reverse4table[] = {
  0, 8, 4, 12, 2, 10, 6, 14,
  1, 9, 5, 13, 3, 11, 7, 15,
};

static inline
uint8_t reversebits(uint8_t v) {
  return (reverse4table[v & 0xf] << 4) | reverse4table[(v & 0xf0) >> 4];
}

static const unsigned char popcount[] = {
  0,1,1,2,1,2,2,3,
  1,2,2,3,2,3,3,4,
  1,2,2,3,2,3,3,4,
  2,3,3,4,3,4,4,5,
  1,2,2,3,2,3,3,4,
  2,3,3,4,3,4,4,5,
  2,3,3,4,3,4,4,5,
  3,4,4,5,4,5,5,6,
  1,2,2,3,2,3,3,4,
  2,3,3,4,3,4,4,5,
  2,3,3,4,3,4,4,5,
  3,4,4,5,4,5,5,6,
  2,3,3,4,3,4,4,5,
  3,4,4,5,4,5,5,6,
  3,4,4,5,4,5,5,6,
  4,5,5,6,5,6,6,7,
  1,2,2,3,2,3,3,4,
  2,3,3,4,3,4,4,5,
  2,3,3,4,3,4,4,5,
  3,4,4,5,4,5,5,6,
  2,3,3,4,3,4,4,5,
  3,4,4,5,4,5,5,6,
  3,4,4,5,4,5,5,6,
  4,5,5,6,5,6,6,7,
  2,3,3,4,3,4,4,5,
  3,4,4,5,4,5,5,6,
  3,4,4,5,4,5,5,6,
  4,5,5,6,5,6,6,7,
  3,4,4,5,4,5,5,6,
  4,5,5,6,5,6,6,7,
  4,5,5,6,5,6,6,7,
  5,6,6,7,6,7,7,8,
};

static inline
int popcountf(uint32_t v) {
  return
    popcount[(v >> 24) & 0xff] +
    popcount[(v >> 16) & 0xff] +
    popcount[(v >> 8) & 0xff] +
    popcount[(v >> 0) & 0xff];
}

template<typename T>
static inline int ms_bit_set (const T& v) {
  for (int i = sizeof(v) * 8 - 1; i > 0; --i) {
    if (v & (1L << i))
      return i;
  }
  return 0;
}

template<typename T>
static inline T rotleft(const T a, unsigned b)
{
  const unsigned bits = sizeof(T) * 8;
  return (a << b) | (a >> (bits - b));
}

template<typename T>
static inline T rotright(const T a, unsigned b)
{
  const unsigned bits = sizeof(T) * 8;
  return (a >> b) | (a << (bits - b));
}

static inline std::ostream& debugbits(std::ostream& s, unsigned code, int bits) {
  for (int i = bits - 1; i >= 0; --i)
    s << (code >> i & 1);
  s << "(#" << bits << ")";
  return s;
}

struct Bitstream {
  Bitstream(std::istream& stream, bool lsbFirst = false)
    : stream(stream), bit(0), z(0), lsbFirst(lsbFirst)
  {
  }
  
  uint32_t operator() (uint32_t v, uint8_t bits) {
    for (uint8_t i = 0; i < bits;) {
      if (bit <= 0) {
	int _z = stream.get();
	if (_z == EOF) {
	  // TODO: maybe throw exception, too?
	  return _z;
	}
	z = _z;
	bit = 8;
	//std::cerr << "bitstream: load: " << lsbFirst << " "; debugbits(std::cerr, z, 8) << std::endl;
      }
      
      const unsigned thisbits = std::min((uint8_t)(bits - i), (uint8_t)bit);
      if (!lsbFirst) {
	v <<= thisbits;
	v |= z >> (8 - thisbits);
	z <<= thisbits;
      } else {
	v |= (z & ((1 << thisbits) - 1)) << i;
	z >>= thisbits;
      }
      
      i += thisbits;
      bit -= thisbits;
    }
    
    //std::cerr << "ret: "; debugbits(std::cerr, v, bits) << std::endl;
    return v;
  }
  
  void align() {
    bit = 0;
  }
  
protected:
  std::istream& stream;
  int8_t bit;
  uint8_t z;
  bool lsbFirst;
};
  
}

#endif // LOWLEVEL__BITS_HH__
