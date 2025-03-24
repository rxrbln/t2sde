/*
 * --- T2-COPYRIGHT-BEGIN ---
 * t2/misc/tools-source/getdu.c
 * Copyright (C) 2004 - 2025 The T2 SDE Project
 * Copyright (C) 1998 - 2003 ROCK Linux Project
 * SPDX-License-Identifier: GPL-2.0
 * --- T2-COPYRIGHT-END ---
 */

#include <stdio.h>
#include <sys/stat.h>
#include <unistd.h>
#include <inttypes.h>
#include <limits.h>

int main(int argc, char ** argv) {
	uint64_t size=0;
	struct stat st;
	char fn[PATH_MAX];
	if (argc > 1) chdir(argv[1]);
	while ( scanf("%*s %s",fn) == 1 ) {
		if ( lstat(fn,&st) ) continue;
		if ( S_ISREG(st.st_mode) ) size+=st.st_size;
		else size+=512; /* Every file has ~512 bytes metadata */
	}
	printf("%.2f MB\n",size/1048576.0);
	return 0;
}
