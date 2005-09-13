// compilation: gcc --shared lzlib.c -o lzlib.so -lz
// contains some slightly addapted code pieces from lua's liolib.c

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
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
  return zf;
}

// ----------------- poor man buffer in C ---------------------

char* content_buffer = NULL;
size_t content_buffer_length = 0;
size_t content_length = 0;

static inline void ResetBuffer ()
{ 
  content_length = 0;
}

static inline void ExtendBuffer (size_t min_size)
{
  if (min_size > content_buffer_length) {
    if (content_buffer_length == 0)
      content_buffer = malloc (min_size);
    else
      content_buffer = realloc (content_buffer, min_size);
    content_buffer_length = min_size;
  }
}

static inline void AddToBuffer (char c)
{
  if (content_buffer_length == content_length)
    ExtendBuffer ((content_buffer_length < 256) ? 256 : 2 * content_buffer_length);
  content_buffer [content_length++] = c;
}

static inline const char* FinishBuffer ()
{
  AddToBuffer ('\0');
  return content_buffer;
}

static inline int BufferFill ()
{
  return content_length;
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
  *zf = NULL;

  // need to emulate pushresult behavior, because gzerror
  // does not work anymore after closing stream *grrrr*

  if (result == Z_OK) {
    lua_pushboolean (L, 1);
    return 1;
  } else {
    const char* zmessage;
    if (result == Z_ERRNO) // error is a file io error
      zmessage = strerror(errno);
    else
      zmessage = zError(result);

    lua_pushnil(L);
    lua_pushfstring(L, zmessage);
    lua_pushinteger(L, result);
    lua_pushinteger(L, errno);
    return 4;
  }
}


static int __gz_lines_iterator (lua_State *L)
{
  gzFile zf = (gzFile) lua_topointer (L, lua_upvalueindex(1));
  int ch;
  ResetBuffer ();

  while ( (ch = gzgetc(zf)) != -1 && ch != '\n') {
    AddToBuffer ((char) ch);
  }

  if (ch == '\n' || BufferFill () > 0) {
    lua_pushstring (L, FinishBuffer ());
    return 1;
  } else {
    return pushresult(L, &zf, NULL);
  }
}


static int gz_lines (lua_State *L)
{
  gzFile *zf = tozfile(L);
  lua_pushlightuserdata (L, *zf);
  lua_pushcclosure (L, __gz_lines_iterator, 1);
  return 1;
}

static int gz_status (lua_State *L)
{
  gzFile *zf = tozfile(L);
  return pushresult (L, zf, NULL);
}

static int gz_eof (lua_State *L)
{
  gzFile *zf = tozfile(L);
  int eof = gzeof (*zf);
  lua_pushboolean(L, eof);
  if (eof == 1) {
    const char* eof_reason;
    int eof_reason_code;
    eof_reason = gzerror (*zf, &eof_reason_code);
    lua_pushboolean (L, eof_reason_code == Z_STREAM_END);
    lua_pushstring (L, eof_reason);
    return 3;
  }
  return 0;
}

// ------------------- init and registering --------------------

static const luaL_reg R[] = {
  {"open", gz_open},
  {"close", gz_close},
  {"lines", gz_lines},
  {"status", gz_status},
  {"eof", gz_eof},
  {NULL, NULL}
};

static const luaL_Reg zlib[] = {
  {"close", gz_close},
  {"lines", gz_lines},
  {"status", gz_status},
  {"eof", gz_eof},
  {"__gc", gz_close},
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
