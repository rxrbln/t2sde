/*
 * Copyright (C) 2008-2015 René Rebe, ExactCODE GmbH
 * Copyright (C) 2008 Valentin Ziegler, ExactCODE GmbH
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


// The aim of this file is to create code for
// FunctionWrapper_*_* and MethodWrapper_*_* classes
// as well as the Call_*_* functions

// Hint: if you want a more readable version of this file,
// use g++ -E

// Sorry for the grave hack,
// c++ templates definitly suck at variadic signatures...

// please port me to the next c++ standard !!

// the macro hackery in this file iterates from N = 7 to N = 0
// and includes this file once for each iteration.

// name(X) is X##N
// ai(X) is "X" if i <= N, ignored otherwise
// aic(X) is ",X" if i <= N, ignored otherwise
// comma is "," if i >= 0
// a0(X) is "X" if i == 0

#ifndef N
#define N 8
#define comma ,
#define a0(X)
#define a1(X) X
#define a1c(X) ,X
#define a2(X) X
#define a2c(X) ,X
#define a3(X) X
#define a3c(X) ,X
#define a4(X) X
#define a4c(X) ,X
#define a5(X) X
#define a5c(X) ,X
#define a6(X) X
#define a6c(X) ,X
#define a7(X) X
#define a7c(X) ,X
#define a8(X) X
#define a8c(X) ,X
#define name(X) X##8
#elif N > 7
#undef N
#undef name
#undef a8
#undef a8c
#define N 7
#define a8(X)
#define a8c(X)
#define name(X) X##7
#elif N > 6
#undef N
#undef name
#undef a7
#undef a7c
#define N 6
#define a7(X)
#define a7c(X)
#define name(X) X##6
#elif N > 5
#undef N
#undef name
#undef a6
#undef a6c
#define N 5
#define a6(X)
#define a6c(X)
#define name(X) X##5
#elif N > 4
#undef N
#undef name
#undef a5
#undef a5c
#define N 4
#define a5(X)
#define a5c(X)
#define name(X) X##4
#elif N > 3
#undef N
#undef name
#undef a4
#undef a4c
#define N 3
#define a4(X)
#define a4c(X)
#define name(X) X##3
#elif N > 2
#undef N
#undef name
#undef a3
#undef a3c
#define N 2
#define a3(X)
#define a3c(X)
#define name(X) X##2
#elif N > 1
#undef N
#undef name
#undef a2
#undef a2c
#define N 1
#define a2(X)
#define a2c(X)
#define name(X) X##1
#elif N > 0
#undef N
#undef comma
#undef name
#undef a1
#undef a1c
#define N 0
#define comma
#define a1(X)
#define a1c(X)
#define name(X) X##0
#undef a0
#define a0(X) X
#endif



// content starts here

template <
  typename RET
  a1c(typename P1)
  a2c(typename P2)
  a3c(typename P3)
  a4c(typename P4)
  a5c(typename P5)
  a6c(typename P6)
  a7c(typename P7)
  a8c(typename P8),
  RET (*F)(a1(P1)a2c(P2)a3c(P3)a4c(P4)a5c(P5)a6c(P6)a7c(P7)a8c(P8))>
class name(FunctionWrapper_1_)
{
public:
  typedef void myobjectT;
  
  static int Wrapper(lua_State* L)
  {
    Pack<RET>::convert(L,
		       F(a1(Unpack<P1>::convert(L, 1))
			 a2c(Unpack<P2>::convert(L, 2))
			 a3c(Unpack<P3>::convert(L, 3))
			 a4c(Unpack<P4>::convert(L, 4))
			 a5c(Unpack<P5>::convert(L, 5))
			 a6c(Unpack<P6>::convert(L, 6))
			 a7c(Unpack<P7>::convert(L, 7))
			 a8c(Unpack<P8>::convert(L, 8))
		        ));
    runAutoRelease(L);
    return 1;
  }

  static const bool hasmeta = false;
  static const bool noindex = true;
};

template <
  a1(typename P1)
  a2c(typename P2)
  a3c(typename P3)
  a4c(typename P4)
  a5c(typename P5)
  a6c(typename P6)
  a7c(typename P7)
  a8c(typename P8)
  comma
  void (*F)(a1(P1)a2c(P2)a3c(P3)a4c(P4)a5c(P5)a6c(P6)a7c(P7)a8c(P8))>
class name(FunctionWrapper_0_)
{
public:
  typedef void myobjectT;
  
  static int Wrapper(lua_State* L)
  {
    F(a1(Unpack<P1>::convert(L, 1))
      a2c(Unpack<P2>::convert(L, 2))
      a3c(Unpack<P3>::convert(L, 3))
      a4c(Unpack<P4>::convert(L, 4))
      a5c(Unpack<P5>::convert(L, 5))
      a6c(Unpack<P6>::convert(L, 6))
      a7c(Unpack<P7>::convert(L, 7))
      a8c(Unpack<P7>::convert(L, 8))
     );
    runAutoRelease(L);
    return 0;
  }

  static const bool hasmeta = false;
  static const bool noindex = true;
};


template <
  a1(typename P1)
  a2c(typename P2)
  a3c(typename P3)
  a4c(typename P4)
  a5c(typename P5)
  a6c(typename P6)
  a7c(typename P7)
  a8c(typename P8)
  comma
  int (*F)(lua_State* a1c(P1)a2c(P2)a3c(P3)a4c(P4)a5c(P5)a6c(P6)a7c(P7)a8c(P8))>
class name(FunctionWrapper_N_)
{
public:
  typedef void myobjectT;
  
  static int Wrapper(lua_State* L)
  {
    int n = F(L
	      a1c(Unpack<P1>::convert(L, 1))
	      a2c(Unpack<P2>::convert(L, 2))
	      a3c(Unpack<P3>::convert(L, 3))
	      a4c(Unpack<P4>::convert(L, 4))
	      a5c(Unpack<P5>::convert(L, 5))
	      a6c(Unpack<P6>::convert(L, 6))
	      a7c(Unpack<P7>::convert(L, 7))
	      a8c(Unpack<P7>::convert(L, 8))
	     );
    runAutoRelease(L);
    return n;
  }

  static const bool hasmeta = false;
  static const bool noindex = true;
};


template <
  typename OBJ, typename DEFOBJ, typename RET
  a1c(typename P1)
  a2c(typename P2)
  a3c(typename P3)
  a4c(typename P4)
  a5c(typename P5)
  a6c(typename P6)
  a7c(typename P7)
  a8c(typename P8)
  ,
  RET (DEFOBJ::*F)(a1(P1)a2c(P2)a3c(P3)a4c(P4)a5c(P5)a6c(P6)a7c(P7)a8c(P8))>
class name(MethodWrapper_1_)
{
public:
  typedef OBJ myobjectT;

  static int Wrapper(lua_State* L)
  {
    RET (DEFOBJ::*f)(a1(P1)a2c(P2)a3c(P3)a4c(P4)a5c(P5)a6c(P6)a7c(P7)a8c(P8)) = F;
    OBJ* obj = Unpack<OBJ*>::convert(L, 1);
    Pack<RET>::convert(L,
		       (obj->*f)(a1(Unpack<P1>::convert(L, 2))
				 a2c(Unpack<P2>::convert(L, 3))
				 a3c(Unpack<P3>::convert(L, 4))
				 a4c(Unpack<P4>::convert(L, 5))
				 a5c(Unpack<P5>::convert(L, 6))
				 a6c(Unpack<P6>::convert(L, 7))
				 a7c(Unpack<P7>::convert(L, 8))
				 a8c(Unpack<P8>::convert(L, 9))
				));
    runAutoRelease(L);
    return 1;
  }

  static const bool hasmeta = true;
  static const bool noindex = false;
};


template <
  typename OBJ,
  typename DEFOBJ
  a1c(typename P1)
  a2c(typename P2)
  a3c(typename P3)
  a4c(typename P4)
  a5c(typename P5)
  a6c(typename P6)
  a7c(typename P7)
  a8c(typename P8)
  ,
  void (DEFOBJ::*F)(a1(P1)a2c(P2)a3c(P3)a4c(P4)a5c(P5)a6c(P6)a7c(P7)a8c(P8))>
class name(MethodWrapper_0_)
{
public:
  typedef OBJ myobjectT;

  static int Wrapper(lua_State* L)
  {
    void (DEFOBJ::*f)(a1(P1)a2c(P2)a3c(P3)a4c(P4)a5c(P5)a6c(P6)a7c(P7)a8c(P8)) = F;
    OBJ* obj = Unpack<OBJ*>::convert(L, 1);
    (obj->*f)(a1(Unpack<P1>::convert(L, 2))
	      a2c(Unpack<P2>::convert(L, 3))
	      a3c(Unpack<P3>::convert(L, 4))
	      a4c(Unpack<P4>::convert(L, 5))
	      a5c(Unpack<P5>::convert(L, 6))
	      a6c(Unpack<P6>::convert(L, 7))
	      a7c(Unpack<P7>::convert(L, 8))
	      a8c(Unpack<P8>::convert(L, 9))
	     );
    runAutoRelease(L);
    return 0;
  }

  static const bool hasmeta = true;
  static const bool noindex = false;
};

template <
  typename OBJ,
  typename DEFOBJ
  a1c(typename P1)
  a2c(typename P2)
  a3c(typename P3)
  a4c(typename P4)
  a5c(typename P5)
  a6c(typename P6)
  a7c(typename P7)
  a8c(typename P8)
  ,
  int (DEFOBJ::*F)(lua_State* a1c(P1)a2c(P2)a3c(P3)a4c(P4)a5c(P5)a6c(P6)a7c(P7)a8c(P8))>
class name(MethodWrapper_N_)
{
public:
  typedef OBJ myobjectT;

  static int Wrapper(lua_State* L)
  {
    int (DEFOBJ::*f)(lua_State* a1c(P1)a2c(P2)a3c(P3)a4c(P4)a5c(P5)a6c(P6)a7c(P7)a8c(P8)) = F;
    OBJ* obj = Unpack<OBJ*>::convert(L, 1);
    int n = (obj->*f)(L
		      a1c(Unpack<P1>::convert(L, 2))
		      a2c(Unpack<P2>::convert(L, 3))
		      a3c(Unpack<P3>::convert(L, 4))
		      a4c(Unpack<P4>::convert(L, 5))
		      a5c(Unpack<P5>::convert(L, 6))
		      a6c(Unpack<P6>::convert(L, 7))
		      a7c(Unpack<P7>::convert(L, 8))
		      a8c(Unpack<P8>::convert(L, 9))
		     );
    runAutoRelease(L);
    return n;
  }

  static const bool hasmeta = true;
  static const bool noindex = false;
};


template <
  typename OBJ
  a1c(typename P1)
  a2c(typename P2)
  a3c(typename P3)
  a4c(typename P4)
  a5c(typename P5)
  a6c(typename P6)
  a7c(typename P7)
  a8c(typename P8)
  >
class name(CtorWrapper_)
{
public:
  typedef OBJ myobjectT;

  static int Wrapper(lua_State* L)
  {
    Pack<OBJ*>::convert(L,
			new OBJ(a1(Unpack<P1>::convert(L, 1))
				a2c(Unpack<P2>::convert(L, 2))
				a3c(Unpack<P3>::convert(L, 3))
				a4c(Unpack<P4>::convert(L, 4))
				a5c(Unpack<P5>::convert(L, 5))
				a6c(Unpack<P6>::convert(L, 6))
				a7c(Unpack<P7>::convert(L, 7))
				a8c(Unpack<P8>::convert(L, 8))
			       ));
    runAutoRelease(L);
    return 1;
  }

  static const bool hasmeta = true;
  static const bool noindex = true;
};


template <
  typename OBJ
  a1c(typename P1)
  a2c(typename P2)
  a3c(typename P3)
  a4c(typename P4)
  a5c(typename P5)
  a6c(typename P6)
  a7c(typename P7)
  a8c(typename P8)
  >
class name(CtorWrapper_N_)
{
public:
  typedef OBJ myobjectT;

  static int Wrapper(lua_State* L)
  {
    Pack<OBJ*>::convert(L,
			new OBJ(L comma
				a1(Unpack<P1>::convert(L, 1))
				a2c(Unpack<P2>::convert(L, 2))
				a3c(Unpack<P3>::convert(L, 3))
				a4c(Unpack<P4>::convert(L, 4))
				a5c(Unpack<P5>::convert(L, 5))
				a6c(Unpack<P6>::convert(L, 6))
				a7c(Unpack<P7>::convert(L, 7))
				a8c(Unpack<P8>::convert(L, 8))
			       ));
    runAutoRelease(L);
    return 1;
  }

  static const bool hasmeta = true;
  static const bool noindex = true;
};


template <
  typename RET
  a1c(typename P1)
  a2c(typename P2)
  a3c(typename P3)
  a4c(typename P4)
  a5c(typename P5)
  a6c(typename P6)
  a7c(typename P7)
  a8c(typename P8)
  ,
  typename DEF
  >
RET name(Call_1_)(lua_State* L, LuaFunctionBase& f
		  a1c(P1 p1)a2c(P2 p2)a3c(P3 p3)a4c(P4 p4)a5c(P5 p5)a6c(P6 p6)a7c(P7 p7)a8c(P8 p8))
  {
    if (f.prepareStack (L)) {
      a1(Pack<P1>::convert(L, p1);)
      a2(Pack<P2>::convert(L, p2);)
      a3(Pack<P3>::convert(L, p3);)
      a4(Pack<P4>::convert(L, p4);)
      a5(Pack<P5>::convert(L, p5);)
      a6(Pack<P6>::convert(L, p6);)
      a7(Pack<P7>::convert(L, p7);)
      a8(Pack<P8>::convert(L, p8);)

      if (lua_pcall(L, N + f.addValues, 1, 0)) {
	std::string err = lua_tostring(L, -1);
	lua_pop(L, 1);
	throw std::runtime_error(err);
      }
	
      RET val = Unpack<RET, DEF>::convert(L, -1);
      lua_pop(L, 1); // pop the returned value
      f.cleanStack(L);
      return val;
    } else
      return getDefault<RET, DEF>(L, -1);
  }


template <
  typename RET
  a1c(typename P1)
  a2c(typename P2)
  a3c(typename P3)
  a4c(typename P4)
  a5c(typename P5)
  a6c(typename P6)
  a7c(typename P7)
  a8c(typename P8)
  >
RET name(Call_1_)(lua_State* L, LuaFunctionBase& f
		  a1c(P1 p1)a2c(P2 p2)a3c(P3 p3)a4c(P4 p4)a5c(P5 p5)a6c(P6 p6)a7c(P7 p7)a8c(P8 p8))
  {
    return name(Call_1_)<RET a1c(P1) a2c(P2) a3c(P3) a4c(P4) a5c(P5) a6c(P6) a7c(P7) a8c(P8), DefaultInitializer<RET> >(
      L, f a1c(p1) a2c(p2) a3c(p3) a4c(p4) a5c(p5) a6c(p6) a7c(p7) a8c(p8)
    );
  }




a1(template <
   a1(typename P1)
   a2c(typename P2)
   a3c(typename P3)
   a4c(typename P4)
   a5c(typename P5)
   a6c(typename P6)
   a7c(typename P7)
   a8c(typename P8)
   >)
  static void
#ifdef __GNUC__
  __attribute__((unused))
#endif
  name(Call_0_)(lua_State* L, LuaFunctionBase& f
		  a1c(P1 p1)a2c(P2 p2)a3c(P3 p3)a4c(P4 p4)a5c(P5 p5)a6c(P6 p6)a7c(P7 p7)a8c(P8 p8))
  {
    if (f.prepareStack(L)) {
      a1(Pack<P1>::convert(L, p1);)
      a2(Pack<P2>::convert(L, p2);)
      a3(Pack<P3>::convert(L, p3);)
      a4(Pack<P4>::convert(L, p4);)
      a5(Pack<P5>::convert(L, p5);)
      a6(Pack<P6>::convert(L, p6);)
      a7(Pack<P7>::convert(L, p7);)
      a8(Pack<P8>::convert(L, p8);)

      if (lua_pcall(L, N + f.addValues, 0, 0)) {
	std::string err = lua_tostring(L, -1);
	lua_pop(L, 1);
	throw std::runtime_error(err);
      }
      
      f.cleanStack(L);
    }
  }



// content end

#if N > 0
#include "LuaWrappers.hh"
#else
#undef N
#undef a0
#undef a1
#undef a1c
#undef a2
#undef a2c
#undef a3
#undef a3c
#undef a4
#undef a4c
#undef a5
#undef a5c
#undef a6
#undef a6c
#undef a7
#undef a7c
#undef a8
#undef a8c
#undef name
#endif
