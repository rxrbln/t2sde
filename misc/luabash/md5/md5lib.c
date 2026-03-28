/*
 * "derived from Cryptographic and Hash functions for Lua".
 * "derived from dietlibc".
 *
 * --- T2-COPYRIGHT-BEGIN ---
 * t2/misc/luabash/md5/md5lib.c
 * Copyright (C) 2006 - 2026 The T2 SDE Project
 * Copyright (C) 2006 Rene Rebe <rene@exactcode.de>
 * Copyright (C) 2005 Roberto Ierusalimschy
 * SPDX-License-Identifier: GPL-2.0
 * --- T2-COPYRIGHT-END ---
 */

#include <stdlib.h>
#include <string.h>
#include <time.h>

#include <lua.h>
#include <lauxlib.h>

#include "md5.h"

#define LUA_FILEHANDLE         "FILE*"
#define topfile(L)      ((FILE **)luaL_checkudata(L, 1, LUA_FILEHANDLE))

static FILE *tofile (lua_State *L) {
  FILE **f = topfile(L);
  if (*f == NULL)
    luaL_error(L, "attempt to use a closed file");
  return *f;
}


/**
*  Hash function. Returns a hash for a given string.
*  @param message: arbitrary binary string.
*  @return  A 128-bit hash string.
*/
static int lmd5 (lua_State *L) {
  char buff[16];
  size_t l;

  const char* message = NULL;
  FILE *f = NULL;

  if (lua_isstring(L, -1))
    message = luaL_checklstring(L, 1, &l);
  else
    f = tofile(L);

    MD5_CTX             context;
    uint8_t             digest [16];
    ssize_t             len;
    char*               t;
    int                 i;
    int                 c;
    char                buf  [1024*4];
    
    MD5Init ( &context );
    
    if (f) {
      while ( (len = fread ( buf, 1, sizeof(buf), f )) > 0 ) {
	MD5Update ( &context, buf, len );
      }
    }
    else
  	MD5Update ( &context, message, l);


  MD5Final ( digest, &context );

  lua_pushlstring(L, digest, 16L);
  return 1;


}


/*
** Assumes the table is on top of the stack.
*/
static void set_info (lua_State *L) {
	lua_pushliteral (L, "_COPYRIGHT");
	lua_pushliteral (L, "Copyright (C) 2003-2006 PUC-Rio");
	lua_settable (L, -3);
	lua_pushliteral (L, "_DESCRIPTION");
	lua_pushliteral (L, "Basic cryptographic facilities");
	lua_settable (L, -3);
	lua_pushliteral (L, "_VERSION");
	lua_pushliteral (L, "1.0.1");
	lua_settable (L, -3);
}


static struct luaL_reg md5lib[] = {
  {"dosum", lmd5},
  {NULL, NULL}
};


int luaopen_md5_core (lua_State *L) {
  luaL_openlib(L, "md5", md5lib, 0);
  set_info (L);
  return 1;
}

