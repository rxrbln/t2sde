#!/bin/sh
# --- T2-COPYRIGHT-BEGIN ---
# t2/misc/archive/cacheinjector.sh
# Copyright (C) 2004 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

config=default
if [ "$1" == "-cfg" ]; then
	config="$2"
	shift; shift
fi

if [ ! -f config/$config/config ]; then
	echo "ERROR: '$config' is not a valid config name"
	exit 1
fi
eval `grep SDECFG_ID= config/$config/config`

FILTER="sed -n -e 's|\[SIZE\].*MB, \\([0-9].*\\)|[SIZE] \1|p' -e '/\\(gawk\|patch\\)/ d;' -e '/^\[DEP\]/ p;'"
echo package/*/*/ | tr ' ' '\n' | 
sed -e "s,^\(.*\)/\(.*\)/\(.*\)/,\3 build/$SDECFG_ID/var/adm/cache/\3 \1/\2/\3/\3.cache," |
	while read pkg new original; do
if [ -f $new ]; then
	if [ ! -f $original ]; then
		echo "ADDING $original"
		cp $new $original
		svn add $original
	else
		eval "$FILTER $new" > $$.new
		eval "$FILTER $original" > $$.original
		if [ "$( diff -u $$.original $$.new )" ]; then
			echo "REPLACING $original"
			cp $new $original
#		else
#			echo "KEEPING $original"
		fi
		rm -f $$.original $$.new
	fi
fi
done
