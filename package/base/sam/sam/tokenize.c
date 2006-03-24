#include <lua.h>
#include <lauxlib.h>

#include <string.h>

static size_t decode(char *buf, size_t len)
{
	/* TODO: escape sequence decoding */
	return len;
}

static int sam_tokenize (lua_State *L) {
	size_t      slen;
	const char *s; /* = luaL_checklstring(L, 1, &slen); */
	char *buf;          /* escape sequence decoding buffer */

#define NONE ((size_t) -1)
	size_t pos = NONE;  /* token start index */
	size_t p;           /* current buffer position */
	char last = ' ';    /* last parsed char */

#define TRUE (~0)
#define FALSE 0

	struct {
		int esc;        /* last character was \ */
		int quote;      /* we are in a quotation */
	} flag = { FALSE, FALSE };

	size_t t = 1;       /* raw table index */

	/* check function arguments */
	if (lua_isnil(L,1)) return 0;

	s = luaL_checklstring(L, 1, &slen);
	
	/* buffer for decoding escape sequences */
	buf = malloc(slen);

	/* create table containg the tokens (retval) */
	lua_newtable(L);

	/* loop over string */
	for(p=0; p<slen; p++) {
		if (!flag.esc) {
			if (s[p] == '\\') {
				flag.esc = TRUE;
			}
			else if (s[p] == '"') {
				if (flag.quote) {
					flag.quote = FALSE;
				}
				else {
					flag.quote = TRUE;
					if (last == ' ') {
						/* start of token */
						pos = p;
					}
				}
			}
			else if (!flag.quote) {
				if ((s[p] == ' ') || (s[p] == '\t')) {
					if (last != ' ') {
						/* end of token */
						size_t len = p-pos;

						strncpy(buf, s+pos, len);
						len = decode(buf, len);

						lua_pushlstring(L, buf, len);
						lua_rawseti(L, -2, t++);
					}
					last = ' ';
					continue;
				}
				else if (last == ' ') {
					/* start of token */
					pos = p;
				}
			}
		}
		else {
			flag.esc = FALSE;
		}

		last = s[p];
	}
	
	/* end of last token */
	if (pos != NONE) {
		size_t len = p - pos;

		strncpy(buf, s+pos, len);
		len = decode(buf, len);

		lua_pushlstring(L, buf, len);
		lua_rawseti(L, -2, t++);
	}
				
	return 1;
}

/*--------------------------------------------------------------------------*/
static const struct luaL_reg functions[] = {
	{"tokenize", sam_tokenize},
	{NULL, NULL}
};

LUALIB_API int luaopen_sam_tokenize (lua_State *L)
{
	luaL_openlib(L, "sam", functions, 0);
	return 1;
}
