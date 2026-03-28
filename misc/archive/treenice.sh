#!/bin/sh
#
# --- T2-COPYRIGHT-BEGIN ---
# t2/misc/archive/treenice.sh
# Copyright (C) 2004 - 2026 The T2 SDE Project
# Copyright (C) 1998 - 2003 ROCK Linux Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

main() {
	renice $newpriority -p $1
	ls /proc/$1/task | xargs renice $newpriority -p
	for y in `cut -f1,4 -d' ' /proc/[0-9]*/stat | grep " $1\$" | cut -f1 -d' '`
	do main $y "$2  " ; done
}

newpriority=$1
shift

if [ $# = 0 ] ; then
	echo "Usage: $0 <new priority> <pid> [ <pid> [ ... ] ]"
	exit 1
else
	for x ; do
		for y in $( ps -e -o pid,comm | tail -n +2 |
			awk "\$1 == \"$x\" || \$2 == \"$x\" { print \$1; }" )
		do
				main $y ""
		done
	done
fi

exit 0
