#!/bin/sh
#
# --- T2-COPYRIGHT-BEGIN ---
# t2/misc/tools-source/fl_wrapper_test.sh
# Copyright (C) 2004 - 2026 The T2 SDE Project
# Copyright (C) 1998 - 2003 ROCK Linux Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

for x in exec{l,v}{,p,e} ; do
touch fltest_$x ; done

bash misc/tools-source/fl_wrapper.c.sh > fl_wrapper.c
gcc -O2 -shared -fPIC -Wall -ldl fl_wrapper.c -o fl_wrapper.so

echo -n > rlog.txt
echo -n > wlog.txt

export FLWRAPPER_RLOG=rlog.txt
export FLWRAPPER_WLOG=wlog.txt

gcc misc/tools-source/fl_wrapper_test.c -o fltest_bin
LD_PRELOAD=./fl_wrapper.so ./fltest_bin

#rm fltest_* fl_wrapper.so
