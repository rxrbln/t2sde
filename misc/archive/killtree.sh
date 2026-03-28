#!/bin/sh
#
# --- T2-COPYRIGHT-BEGIN ---
# t2/misc/archive/killtree.sh
# Copyright (C) 2004 - 2026 The T2 SDE Project
# Copyright (C) 1998 - 2003 ROCK Linux Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

main() {
	for y in `cut -f1,4 -d' ' /proc/*/stat | grep " $1\$" | cut -f1 -d' '`
	do main $y "$2  " ; done
	out="$( kill -$signal $1 2>&1 )"
	if [ "$out" ] ; then echo "$2$out"
	else echo "$2""Killing PID $1." ; fi
}

signal=$1
shift

if [ $# = 0 ] ; then
	echo "Usage: $0 <signal> <pid> [ <pid> [ ... ] ]"
	exit 1
else
	for x ; do
		echo
		echo "Killing tree $x upside-down:"
		main $x ""
	done
	echo
fi

exit 0
