/*
 * --- T2-COPYRIGHT-BEGIN ---
 * t2/misc/tools-source/fl_wrapper_test.c
 * Copyright (C) 2004 - 2026 The T2 SDE Project
 * Copyright (C) 1998 - 2003 ROCK Linux Project
 * SPDX-License-Identifier: GPL-2.0
 * --- T2-COPYRIGHT-END ---
 */

#include <unistd.h>

int main(int argc, char ** argv, char ** env) {

	/* Test various exec calls() */
	execl( "./fltest_execl",  NULL);
	execlp("./fltest_execlp", NULL);
	execle("./fltest_execle", NULL, env);
	execv( "./fltest_execv",  argv);
	execvp("./fltest_execvp", argv);
	execve("./fltest_execve", argv, env);

	/* Test PATH evaluation */
	execlp("ls", "ls", NULL);
}
