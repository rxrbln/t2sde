// contains some slightly addapted code pieces from lua's liolib.c

#include <stdio.h>
#include <errno.h>
#include <zlib.h>
#include <lua.h>
#include <lauxlib.h>

#define ZLIB_HANDLE "gzFile"

// ------------------- helper functions ------------------------ 

// pushes gzFile operation result string on lua stack

// first value is either true or nil (== operation failed),
// in the latter case a string containing the error message and
// the nummerical error codes (gzerror / errno) are returned
// as additional values

static int pushresult (lua_State *L, gzFile* zf, const char *filename)
{
  int zlib_result;
  const char* zmessage;
  if ((zf) == NULL)
    zlib_result = Z_ERRNO;
  else
    zmessage = gzerror (*zf, &zlib_result);

  if (zlib_result == Z_OK) {
    lua_pushboolean(L, 1);
    return 1;
  } else {

    if (zlib_result == Z_ERRNO) // error is a file io error
      zmessage = strerror(errno);

    lua_pushnil(L);

    if (filename)
      lua_pushfstring(L, "%s: %s", filename, zmessage);
    else
      lua_pushfstring(L, "%s", zmessage);

    lua_pushinteger(L, zlib_result);
    lua_pushinteger(L, errno);
    return 4;
  }
}

// ensures first argument is an open zlib handle and returns it
static gzFile *tozfile (lua_State *L)
{
  gzFile *zf = ((gzFile *) luaL_checkudata(L, 1, ZLIB_HANDLE));

  if (*zf == NULL)
    luaL_error(L, "attempt to use a closed gz file");
  return *zf;
}

// -------------------------- API ------------------------------

static int gz_open (lua_State *L)
{
  const char *filename = luaL_checkstring(L, 1);
  const char *mode = luaL_optstring(L, 2, "r");

  gzFile* zf = (gzFile *) lua_newuserdata(L, sizeof(gzFile));
  luaL_getmetatable(L, ZLIB_HANDLE);
  lua_setmetatable(L, -2);

  *zf = gzopen(filename, mode);

  return (*zf == NULL) ? pushresult(L, NULL, filename) : 1;
}

static int gz_close (lua_State *L)
{
  gzFile *zf = tozfile(L);
  int result = gzclose(*zf);
  int value_count = pushresult(L, *zf, NULL);
  if (result == 0)
    *zf = NULL;
  return value_count;
}

// ------------------- init and registering --------------------

static const luaL_reg R[] = {
  {"open", gz_open},
  {NULL, NULL}
};

static const luaL_Reg zlib[] = {
  {"close", gz_close},
  {NULL, NULL}
};

static void createmeta (lua_State *L) {
  luaL_newmetatable(L, ZLIB_HANDLE);  /* create metatable for zlib handles */
  lua_pushvalue(L, -1);  /* push metatable */
  lua_setfield(L, -2, "__index");  /* metatable.__index = metatable */
  luaL_register(L, NULL, zlib);  /* gz file methods */
}

LUALIB_API int luaopen_lzlib (lua_State *L)
{
  createmeta(L);
  luaL_openlib(L, "lzlib", R, 0);
  lua_pushliteral(L,"version");           /** version */
  lua_pushliteral(L,"pre-alpha");
  lua_settable(L,-3);
  return 1;
}
