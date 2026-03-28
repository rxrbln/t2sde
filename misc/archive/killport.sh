#!/bin/sh
#
# --- T2-COPYRIGHT-BEGIN ---
# t2/misc/archive/killport.sh
# Copyright (C) 2004 - 2026 The T2 SDE Project
# Copyright (C) 1998 - 2003 ROCK Linux Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

signal=15
returncode=0

for port ; do
	xport="`printf '%04X' $port 2> /dev/null || echo ERROR`"
	if [ "$xport" = "ERROR" ] ; then
		echo "Not a valid port number: $port" >&2
		returncode=$(($returncode + 1))
	else
	    echo "Sending signal $signal to all processes connected" \
	         "to port $port:"

	    for proto in tcp udp ; do
		echo -n "  Inodes for `echo $proto | tr a-z A-Z`/$xport: "
		inodes=`egrep "^ *[0-9]+: +[0-9A-F]+:$xport " /proc/net/$proto |
		       tr -s ' ' | cut -f11 -d' ' | tr '\n' ' '`
		if [ "$inodes" ] ; then
		    echo "$inodes (getting pids)"
		    for inode in $inodes ; do
			echo -n "    PIDs for inode $inode: "
			pids="`ls -l /proc/[0-9]*/fd/* 2> /dev/null | \
			       grep 'socket:\['$inode'\]' | tr -s ' ' |
			       cut -f9 -d' ' | cut -f3 -d/ | tr '\n' ' '`"
			if [ "$pids" ] ; then
				echo "$pids (sending signal)"
				kill -$signal $pids
			else
				echo "None found."
			fi
		    done
		else
			echo "None found."
		fi
	    done
	fi
done

exit $returncode
