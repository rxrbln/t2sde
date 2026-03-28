/*
 * --- T2-COPYRIGHT-BEGIN ---
 * t2/misc/tools-source/getfiles.c
 * Copyright (C) 2004 - 2026 The T2 SDE Project
 * Copyright (C) 1998 - 2003 ROCK Linux Project
 * SPDX-License-Identifier: GPL-2.0
 * --- T2-COPYRIGHT-END ---
 */

#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

int main(int argc, char ** argv) {
	char *fn, buf[512], *n;
	struct stat st;
	if (argc > 1) chdir(argv[1]);
	while ( fgets(buf, 512, stdin) != NULL &&
					(fn = strchr(buf, ' ')) != NULL ) {
		if ( (n = strchr(++fn, '\n')) != NULL ) *n = '\0';
		if ( !lstat(fn,&st) && S_ISREG(st.st_mode) )
			puts(fn);
	}
	return 0;
}
