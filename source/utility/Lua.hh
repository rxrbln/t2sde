/*
 * Copyright (C) 2009-2017 René Rebe, ExactCODE GmbH
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

#ifndef __LUA_HH
#define __LUA_HH

extern "C" {
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
}

#ifndef lua_pushglobaltable // Lua 5.1 et al.
#define lua_pushglobaltable(L) lua_pushvalue(L, LUA_GLOBALSINDEX)
#endif

#include <string.h>
#include <string>
#include <vector>
#include <algorithm>
#include <stdexcept>

namespace LuaWrapper {

  template <typename T> class typeName;

  template <>
  class typeName<int>
  {
  public:
    static const char* name() {return "int"; }
  };

  template <>
  class typeName<unsigned int>
  {
  public:
    static const char* name() {return "unsigned int"; }
  };

  template <>
  class typeName<double>
  {
  public:
    static const char* name() {return "double"; }
  };

  template <>
  class typeName<const char*>
  {
  public:
    static const char* name() {return "const char*"; }
  };

  template <>
  class typeName<bool>
  {
  public:
    static const char* name() {return "bool"; }
  };

  template <>
  class typeName<std::string>
  {
  public:
    static const char* name() {return "std::string"; }
  };



  static void argError(lua_State* L, int index, const char* type_name)
  {
    // slightly adapted from luaL_argerror and luaL_typerror

      lua_Debug ar;
      if (!lua_getstack(L, 0, &ar))  /* no stack frame? */
	ar.name = "?";
      else
	lua_getinfo(L, "n", &ar);
      if (ar.name == NULL)
	ar.name = "?";
      luaL_error(L, "cannot convert argument #%d from %s to %s (current stackframe: " LUA_QS " )",
		 index, luaL_typename(L, index), type_name, ar.name);
  }



  template <typename T, T RET, bool MARK=false>
  class DefaultConst
  {
  public:
		DefaultConst(lua_State* L, int index) { if (MARK) lua_pushnil(L); };
    static const T ret = RET;
  };
  
  template <typename T, bool MARK=false>
  class DefaultInitializer
  {
  public:
		DefaultInitializer(lua_State* L, int index) : ret() { if (MARK) lua_pushnil(L); };
    T ret;
  };
  

  template <typename T>
  class TypeError
  {
  public:
    TypeError(lua_State* L, int index) : ret()
    {
      argError(L, index, typeName<T>::name() );
    }
    
    T ret;
  };

  template <typename T>
  class TypeError<T&>
  {
  public:
    TypeError(lua_State* L, int index) : ret()
    {
      argError(L, index, typeName<T>::name());
    }
    
    T* ret;
  };

  template <typename T>
  class TypeError<const T&>
  {
  public:
    TypeError(lua_State* L, int index) : ret()
    {
      argError(L, index, typeName<T>::name());
    }
    
    T* ret;
  };



  template <>
  class TypeError<const std::string&>
  {
  public:
   TypeError(lua_State* L, int index)
    {
      argError(L, index, typeName<std::string>::name());
    }
    
    std::string ret;
  };

  template <typename T, typename DEF>
  T getDefault(lua_State* L, int index) {
    DEF def(L, index);
    return def.ret;
  }


  class LuaClassData
  {
  public:
    LuaClassData(const char* name)
      : handle(name) {
    }

    bool isCompatible(lua_State* L, int index) {
      // modelled after Lua 5.2+ luaL_testudata()
      if (lua_getmetatable(L, index)) { // does it have a metatable?
	luaL_getmetatable(L, handle); // get correct metatable 
	bool ret = lua_rawequal(L, -1, -2); // if not the same userdata with wrong metatable
	lua_pop(L, 2); // remove both metatables
	return ret;
      }
      return false; // value is not a userdata with a metatable
    }
    
    const char* handle;
  };

  template <typename T>
  class LuaClass
  {
  public:
    LuaClass(const char* name)
    {
      if (!data) {
	data = new LuaClassData(name);
      }
    }
    
    ~LuaClass()
    {
      if (data) {
	delete data; data = 0;
      }
    }
    
    static const char* luahandle()
    {
      return data->handle;
    }
  
    static T* getPtr(lua_State* L, int index)
    {
      T** p = getRawPtr(L, index);
      if (p)
	  return (T*)*p;
      //luaL_typerror(L, index, luahandle());
      return 0;  /* avoid warnings */
    }

    static T** getRawPtr(lua_State* L, int index)
    {
      void** p = (void**)lua_touserdata(L, index);
      if (p)
	if (data->isCompatible(L, index))
	  return (T**)p;
      
      //luaL_typerror(L, index, luahandle());
      return 0;  /* avoid warnings */
    }

    static void packPtr(lua_State* L, T* obj)
    {
      T** ptr = (T**)lua_newuserdata(L, sizeof(T*));
      *ptr = obj;
      luaL_getmetatable(L, luahandle());
      lua_setmetatable(L, -2);
    }

    static LuaClassData* data;
  };

  template <typename T>
  LuaClassData* LuaClass<T>::data = 0;


  class AutoReleaseItem
  {
  public:
    AutoReleaseItem(lua_State* L);
    virtual ~AutoReleaseItem() {}
    AutoReleaseItem* next;
  };

  template <typename T>
  class EncapsulatedReleaseItem : public AutoReleaseItem
  {
  public:
    T t;
    EncapsulatedReleaseItem(const T& init, lua_State* L)
      : AutoReleaseItem(L), t(init) {
    }
  };

  template <typename T>
  class ReleaseReferenceReleaseItem : public AutoReleaseItem
  {
  public:
    T t;
    ReleaseReferenceReleaseItem(const T& init, lua_State* L)
      : AutoReleaseItem(L), t(init) {
    }
    
    ~ReleaseReferenceReleaseItem() {
      t.releaseReference();
    }
  };

  void runAutoRelease(lua_State* L);

  class LuaTable
  {
  public:
    int handle;
    lua_State* my_L;

    LuaTable() // stub ctor, for default initializers etc
    {
      // make sure misuse of this constructor in code is noticed quickly
      my_L = 0; 
      handle = 0;
    }

    LuaTable(lua_State* L) // create a new table and reference
    {
      lua_newtable(L);
      handle = luaL_ref(L, LUA_REGISTRYINDEX);
      my_L = L;
    }

    LuaTable(lua_State* L, int stackIndex) // reference a table on stack
    {
      if (lua_type(L, stackIndex) == LUA_TTABLE) {
	lua_pushvalue(L, stackIndex);
	handle = luaL_ref(L, LUA_REGISTRYINDEX);
	my_L = L;
      } else {
	my_L = 0;
	handle = 0;
      }
    }

    LuaTable(const LuaTable& src)
    {
      handle = src.handle;
      my_L = src.my_L;
    }

    void push()
    {
      lua_rawgeti(my_L, LUA_REGISTRYINDEX, handle);
    }

    void autoRelease()
    {
      new ReleaseReferenceReleaseItem<LuaTable>(*this, my_L);
    }

    void releaseReference()
    {
      luaL_unref(my_L, LUA_REGISTRYINDEX, handle);
      my_L = 0;
    }
    
    bool valid() const
    {
      return my_L != 0;
    }
    
    operator bool() const
    {
      return valid();
    }
    
    int size()
    {
      push();
      int result = lua_objlen(my_L, -1);
      lua_pop(my_L, 1);
      return result;
    }
    
    bool exists(const char* key)
    {
      push();
      lua_getfield(my_L, -1, key);
      bool result = (lua_isnil(my_L, -1) == 0);
      lua_pop(my_L, 2);
      return result;
    }
    
    bool exists(int ikey)
    {
      push();
      lua_pushinteger(my_L, ikey);
      lua_gettable(my_L, -2);
      bool result = (lua_isnil(my_L, -1) == 0);
      lua_pop(my_L, 2);
      return result;
    }

    template <typename T, typename DEF > T getD(const char* key);
    template <typename T, typename DEF > T getD(int ikey);

    template <typename T> T get(const char* key)
    {
      return getD <T, DefaultInitializer<T> > (key);
    }

    template <typename T> T get(int ikey)
    {
      return getD <T, DefaultInitializer<T> > (ikey);
    }

    template <typename T> T defaultGet(const char* key, T def);
    template <typename T> T defaultGet(int ikey, T def);
		

    template <typename T> void set(const char* key, T obj);
    template <typename T> void set(int ikey, T obj);
      
  };

  class LuaFunctionBase
  {
  public:
    virtual bool prepareStack(lua_State* L) = 0;
    virtual void cleanStack(lua_State* L) = 0;
    int addValues;
  };

  class Global : public LuaFunctionBase
  {
  public:
    Global(const char* function_name)
    {
      addValues = 0;
      name = function_name;
    }

    virtual bool prepareStack(lua_State* L)
    {
      lua_pushglobaltable(L);
      lua_getfield(L, -1, name);
      if (!lua_isfunction(L, -1)) {
	lua_pop(L, 1);
	return false;
      }
      return true;
    }

    virtual void cleanStack(lua_State* L) {}
    const char* name;
  };

  class Method : public LuaFunctionBase
  {
  public:
    Method(LuaTable obj, const char* function_name)
      : table(obj)
    {
      addValues = 1;
      name = function_name;
    }
    
    virtual bool prepareStack(lua_State* L)
    {
      if (table.my_L != L)
	return false;

      table.push();
      lua_getfield(L, -1, name);
      if (!lua_isfunction(L, -1)) {
	lua_pop(L, 2);
	return false;
      }
      lua_pushvalue(L, -2); // first arg is self
      return true;
    }

    virtual void cleanStack(lua_State* L)
    {
      lua_pop(L, 1); // remove table reference from stack
    }

    const char* name;
    LuaTable table;
  };
  
  class LuaFunction : public LuaFunctionBase
  {
  public:
    int handle;
    lua_State* my_L;

    LuaFunction() // stub ctor, for default initializers etc
    {
      my_L = 0; // make sure missuse of this constructor in code
      // be noticed quick ;)
      handle = 0;
      addValues = 0;
    }

    LuaFunction(lua_State* L, int stackIndex) // reference a function on stack
    {
      if (lua_type(L, stackIndex) == LUA_TFUNCTION) {
	lua_pushvalue(L, stackIndex);
	handle = luaL_ref(L, LUA_REGISTRYINDEX);
	my_L = L;
      } else {
	my_L = 0;
	handle =0;
      }
      addValues = 0;
    }

    LuaFunction(const LuaFunction& src)
    {
      handle = src.handle;
      my_L = src.my_L;
      addValues = 0;
    }
    
    virtual ~LuaFunction() {};
    
    virtual bool prepareStack(lua_State* L)
    {
      if (my_L != L)
	return false;
      lua_rawgeti(my_L, LUA_REGISTRYINDEX, handle);
      return true;
    }

    virtual void cleanStack(lua_State* L)
    {
    }

    void releaseReference()
    {
      luaL_unref(my_L, LUA_REGISTRYINDEX, handle);
      my_L = 0;
    }
  };

  template <>
  class typeName<LuaTable>
  {
  public:
    static const char* name() {return "LuaWrapper::LuaTable"; }
  };

  template <>
  class typeName<LuaFunction>
  {
  public:
    static const char* name() {return "LuaWrapper::LuaFunction"; }
  };


  
  template <typename T>
  class typeName
  {
  public:
    static const char* name() { return LuaClass<T>::luahandle(); }
  };

  template <typename T>
  class typeName<T&> : public typeName<T> {};

  template <typename T>
  class typeName<const T&> : public typeName<T> {};

  template <typename T>
  class typeName<T*> : public typeName<T> {};



  template <typename T, typename DEF=TypeError<T> >
  class Unpack {};

  template <typename DEF>
  class Unpack<int, DEF>
  {
  public:
    static int convert(lua_State* L, int index)
    {
      lua_Integer d = lua_tointeger(L, index);
      if (d == 0 && !lua_isnumber(L, index))
	return getDefault<int, DEF>(L, index);
      return (int) d;
    }
  };

  template <typename DEF>
  class Unpack<unsigned int, DEF>
  {
  public:
    static unsigned int convert(lua_State* L, int index)
    {
      lua_Integer d = lua_tointeger(L, index);
      if (d == 0 && !lua_isnumber(L, index))
	return getDefault<unsigned int, DEF>(L, index);
      return (unsigned int) d;
    }
  };

  template <typename DEF>
  class Unpack<double, DEF>
  {
  public:
    static double convert(lua_State* L, int index)
    {
      lua_Number d = lua_tonumber(L, index);
      if (d == 0 && !lua_isnumber(L, index))
	return getDefault<double, DEF>(L, index);
      return (double) d;
    }
  };

  template <typename DEF>
  class Unpack<bool, DEF>
  {
  public:
    static bool convert(lua_State* L, int index)
    {
      if (lua_type(L, index) != LUA_TBOOLEAN)
	return getDefault<bool, DEF>(L, index);
      return lua_toboolean(L, index) == 0 ? false : true; 
    }
  };

  template <typename DEF>
  class Unpack<const char*, DEF>
  {
  public:
    static const char* convert(lua_State* L, int index)
    {
      const char* str = lua_tostring(L, index);
      if (str == 0)
	return getDefault<const char*, DEF>(L, index);
      return str;
    }
  };

  template <typename DEF>
  class Unpack<std::string, DEF>
  {
  public:
    static std::string convert(lua_State* L, int index)
    {
      size_t strlen = 0;
      const char* str = lua_tolstring(L, index, &strlen);
      if (str == 0)
	return getDefault<std::string, DEF>(L, index);
      return std::string(str, strlen);
    }
  };

  template <typename DEF>
  class Unpack<std::string&, DEF>
  {
  public:
    static std::string& convert(lua_State* L, int index)
    {
      typedef EncapsulatedReleaseItem<std::string> AutoRelease;
      AutoRelease* rel = new AutoRelease(Unpack<std::string, DEF>::convert(L, index), L);
      return rel->t;
    }
  };

  template <typename DEF>
  class Unpack<const std::string&, DEF>
  {
  public:
    static const std::string& convert(lua_State* L, int index)
    {
      typedef EncapsulatedReleaseItem<std::string> AutoRelease;
      AutoRelease* rel = new AutoRelease(Unpack<std::string, DEF>::convert(L, index), L);
      return rel->t;
    }
  };

  template <typename DEF>
  class Unpack<LuaTable, DEF>
  {
  public:
    static LuaTable convert(lua_State* L, int index)
    {
      LuaTable t(L, index);
      if (t.my_L == 0)
	return getDefault<LuaTable, DEF>(L, index);
      return t;
    }
  };
  
  template <typename DEF>
  class Unpack<LuaFunction, DEF>
  {
  public:
    static LuaFunction convert(lua_State* L, int index)
    {
      LuaFunction f(L, index);
      if (f.my_L == 0)
	return getDefault<LuaFunction, DEF>(L, index);
      return f;
    }
  };


  template <typename T, typename DEF>
  class Unpack<T*, DEF>
  {
  public:
    static T* convert(lua_State* L, int index)
    {
      T* t=LuaClass<T>::getPtr(L, index);
      if (t == 0)
	return getDefault<T*, DEF>(L, index);
      return t;
    }
  };


  template <typename T, typename DEF >
  class Unpack<T&, DEF>
  {
  public:
    static T& convert(lua_State* L, int index)
    {
      return *( Unpack<T*, DEF>::convert(L, index) );
    }
  };

  template <typename T, typename DEF>
  class Unpack<const T&, DEF>
  {
  public:
    static const T& convert(lua_State* L, int index)
    {
      return *( Unpack<T*, DEF>::convert(L, index) );
    }
  };


  template <typename T>
  class Pack {};

  template <>
  class Pack<int>
  {
  public:
    static void convert(lua_State* L, int value)
    {
      lua_pushinteger(L, value);
    }
  };

  template <>
  class Pack<unsigned int>
  {
  public:
    static void convert(lua_State* L, unsigned int value)
    {
      lua_pushinteger(L, value);
    }
  };

  template <>
  class Pack<float>
  {
  public:
    static void convert(lua_State* L, float value)
    {
      lua_pushnumber(L, value);
    }
  };

  template <>
  class Pack<double>
  {
  public:
    static void convert(lua_State* L, double value)
    {
      lua_pushnumber(L, value);
    }
  };

  template <>
  class Pack<bool>
  {
  public:
    static void convert(lua_State* L, bool value)
    {
      lua_pushboolean(L, value);
    }
  };

  template <>
  class Pack<const char*>
  {
  public:
    static void convert(lua_State* L, const char* value)
    {
      lua_pushstring(L, value);
    }
  };

  template <>
  class Pack<std::string>
  {
  public:
    static void convert(lua_State* L, std::string value)
    {
      lua_pushlstring(L, value.c_str(), value.size());
    }
  };

  template <>
  class Pack<std::string&>
  {
  public:
    static void convert(lua_State* L, std::string value)
    {
      lua_pushlstring(L, value.c_str(), value.size());
    }
  };

  template <>
  class Pack<const std::string&>
  {
  public:
    static void convert(lua_State* L, std::string value)
    {
      lua_pushlstring(L, value.c_str(), value.size());
    }
  };

  template <>
  class Pack<LuaTable>
  {
  public:
    static void convert(lua_State* L, LuaTable value)
    {
      value.push();
    }
  };
  
  template <>
  class Pack<LuaFunction>
  {
  public:
    static void convert(lua_State* L, LuaFunction value)
    {
      value.prepareStack(L);
    }
  };
 

  template <typename T>
  class Pack <T*>
  {
  public:
    static void convert(lua_State* L, T* obj)
    {
      LuaClass<T>::packPtr(L, obj);
    }
  };

  template <typename T>
  class Pack <T&>
  {
  public:
    static void convert(lua_State* L, T& obj)
    {
      LuaClass<T>::packPtr(L, *obj);
    }
  };


  template <typename T, typename DEF> T LuaTable::getD(const char* key)
  {
    push();
    lua_getfield(my_L, -1, key);
    T ret = Unpack<T, DEF>::convert(my_L, -1);
    lua_pop(my_L, 2);
    return ret;
  }

  template <typename T, typename DEF> T LuaTable::getD(int ikey)
  {
    push();
    lua_pushinteger(my_L, ikey);
    lua_gettable(my_L, -2);
    T ret = Unpack<T, DEF>::convert(my_L, -1);
    lua_pop(my_L, 2);
    return ret;
  }

  template <typename T> T LuaTable::defaultGet(const char* key, T def)
	{
		push();
		lua_getfield(my_L, -1, key);
		T ret = Unpack<T, DefaultInitializer<T, true> >::convert(my_L, -1);
		if (lua_isnil(my_L, -1)) {
			set(key, def);
			lua_pop(my_L, 3);
			return def;
		}
		lua_pop(my_L, 2);
		return ret;
	}

	template <typename T> T LuaTable::defaultGet(int ikey, T def)
	{
			push();
			lua_pushinteger(my_L, ikey);
			lua_gettable(my_L, -2);
			T ret = Unpack<T, DefaultInitializer<T, true> >::convert(my_L, -1);
			if (lua_isnil(my_L, -1)) {
				set(ikey, def);
				lua_pop(my_L, 3);
				return def;
			}
			lua_pop(my_L, 2);
			return ret;
	}

  template <typename T> void LuaTable::set(const char* key, T obj)
  {
    push();
    Pack<T>::convert(my_L, obj);
    lua_setfield(my_L, -2, key);
    lua_pop(my_L, 1);
  }

  template <typename T> void LuaTable::set(int ikey, T obj)
  {
    push();
    lua_pushinteger(my_L, ikey);
    Pack<T>::convert(my_L, obj);
    lua_settable(my_L, -3);
    lua_pop(my_L, 1);
  }

  template <typename ORIG, typename ALIAS>
  class UnpackTypedef
  {
  public:
    static ALIAS convert(lua_State* L, int index)
    {
      return (ALIAS)Unpack<ORIG>::convert(L, index);
    }
  };

  template <typename ORIG, typename ALIAS>
  class PackTypedef
  {
  public:
    static void convert(lua_State* L, ALIAS value)
    {
      Pack<ORIG>::convert(L, (ORIG)value);
    }
  };


#include "LuaWrappers.hh"

  // does not need to be expanded in LuaWrappers.hh hackery, since
  // dtors never take arguments ;)
  template <typename OBJ>
  class DtorWrapper
  {
  public:
    typedef OBJ myobjectT;

    static int Wrapper(lua_State* L)
    {
      OBJ** obj = LuaClass<OBJ>::getRawPtr(L, 1);
      if (*obj) {
	delete *obj; *obj = 0;
      }
      return 0;
    }

    static const bool hasmeta = true;
    static const bool noindex = false;
  };



  template <typename WRAPPER>
  class ExportToLua {
  public:
    typedef typename WRAPPER::myobjectT objectT;

    ExportToLua(lua_State* L, const char* module_name, const char* function_name)
    {
      luaL_Reg entry[2] = {{function_name, WRAPPER::Wrapper}, {NULL, NULL}};
      if (WRAPPER::hasmeta) {
	luaL_getmetatable(L, LuaClass<objectT>::luahandle());
	if (strncmp(function_name, "__", 2) != 0 && !WRAPPER::noindex) {
	  lua_getfield(L, -1, "__index");
	  luaL_register(L, 0, entry);
	  lua_pop(L, 2);
	} else { // allow direct registration of ctors and __* methods
	  luaL_register(L, 0, entry);
	  lua_pop(L, 1);
	}
      } else {
	luaL_register(L, module_name, entry);
	lua_pop(L, 1);
      }
    }
  };

  template <typename T>
  void DeclareToLua(lua_State* L, const char* module_name = 0)
  {
    luaL_newmetatable(L, LuaClass<T>::luahandle());

    if (module_name) {
      // drop a reference to the metatable into the module table
      lua_pushglobaltable(L);
      luaL_findtable(L, -1, module_name, 1);
      lua_remove(L, -2); // globaltable
      lua_pushvalue(L, -2);
      lua_setfield(L, -2, LuaClass<T>::luahandle());
      lua_pop(L, 1);
    }

    // create index table
    lua_newtable(L);
    lua_setfield(L, -2, "__index");
    lua_pop(L, 1);
  }

  template <typename BASE, typename DERIVED>
  void InheritMeta(lua_State* L)
  {
    luaL_getmetatable(L, LuaClass<DERIVED>::luahandle()); // -5
    lua_getfield(L, -1, "__index"); // -4
    luaL_getmetatable(L, LuaClass<BASE>::luahandle()); // -3
    lua_getfield(L, -1, "__index"); // -2

    lua_pushnil(L);  /* -1 first key */
    while (lua_next(L, -2) != 0) {
      lua_pushvalue(L, -2); // copy key and move down
      lua_insert(L, -3);
      lua_settable(L, -6); // DERIVED __index at -6
    }
    lua_pop(L, 5);
  }

  template <typename BASE, typename DERIVED>
  void AllowDowncast(lua_State* L)
  {
    luaL_getmetatable(L, LuaClass<DERIVED>::luahandle());
    // NYI: if used allow re-implement with new direct meta comparision
    LuaClass<BASE>::data->insertMetaTablePtr((void*)lua_topointer(L, -1));
    lua_pop(L, 1);
  }

  template <typename C>
  void RegisterValue(lua_State* L, const char* module_name, const char* name, C value)
  {
    lua_pushglobaltable(L);
    luaL_findtable(L, -1, module_name, 1);
    lua_remove(L, -2); // globaltable
    Pack<C>::convert(L, value);
    lua_setfield(L, -2, name);
    lua_pop(L, 1);
  }

  // convenient helper
  inline void dumpStack (lua_State* L)
  {
    int top = lua_gettop(L);
    for (int i = 1; i <= top; ++i)
    {
      int t = lua_type(L, i);
      switch (t) {
        case LUA_TSTRING:	printf("'%s' ", lua_tostring(L, i)); break;
        case LUA_TBOOLEAN:	printf("%s ", lua_toboolean(L, i) ? "true" : "false"); break;
        case LUA_TNUMBER:	printf("%g ", lua_tonumber(L, i)); break;
        default:		printf("%s ", lua_typename(L, t)); break;
      }
    }
    printf("\n");
  }

  inline void insertLoader(lua_State* L, int (*fptr)(lua_State* L))
  {
    lua_pushglobaltable(L);
    luaL_findtable(L, -1, "package.loaders", 0);
    LuaWrapper::LuaTable loaders(L, -1);
    lua_pop(L, 2);

    int i = 1;
    while (loaders.exists(i))
      ++i;

    // move all loaders by one, to insert ours at the first index
    for (; i > 0; --i)
    {
      loaders.push(); // tables registry handle
      lua_pushinteger(L, i);
      if (i > 1) {
        lua_pushinteger(L, i - 1);
        lua_gettable(L, -3);
        lua_settable(L, -3);
      }
      else {
        lua_pushcclosure(L, fptr, 0);
        lua_settable(L, -3);
      }
      lua_pop(L, 1); // table ref
    }
    loaders.releaseReference();
  }
}


// some convenient defines:
#define ToLuaTypedef(ORIG, ALIAS) \
namespace LuaWrapper { \
  template <> class Unpack<ALIAS>:public UnpackTypedef<ORIG, ALIAS>{}; \
  template <> class Pack<ALIAS>:public PackTypedef<ORIG, ALIAS>{}; }


#endif
