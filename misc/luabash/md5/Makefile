# --- T2-COPYRIGHT-BEGIN ---
# t2/misc/luabash/md5/Makefile
# Copyright (C) 2006 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---


CFLAGS = -g -O2

md5.so: md5.o md5lib.o
	$(CC) -shared  -o '$@' $^
