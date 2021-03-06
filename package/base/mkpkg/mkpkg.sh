#!/bin/bash
# --- T2-COPYRIGHT-NOTE-BEGIN ---
# This copyright note is auto-generated by ./scripts/Create-CopyPatch.
# 
# T2 SDE: package/.../mkpkg/mkpkg.sh
# Copyright (C) 2004 - 2006 The T2 SDE Project
# Copyright (C) 2003 - 2003 ROCK Linux Project
# 
# More information can be found in the files COPYING and README.
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License. A copy of the
# GNU General Public License can be found in the file COPYING.
# --- T2-COPYRIGHT-NOTE-END ---

if [ "$#" -lt 2 -o -z "$1" -o -z "${1##-*}" ]; then
	echo ""
	echo "Usage: $0 <pkg-name> <install-command>"
	echo ""
	echo "E.g.:"
	echo ""
	echo "	cd /usr/local/src/foobar-1.0"
	echo "	./configure && make"
	echo "	mkpkg foobar make install"
	echo ""
	exit 1
fi

pkg=$1; shift
slog=`mktemp` wlog=`mktemp` flog=`mktemp`

strace -o $slog -F -f -q -e open,creat,`
	`mkdir,mknod,link,symlink,rename,utime,chdir,`
	`execve,fork,vfork,_exit,exit_group -p $$ &
strace_pid=$!; sleep 1; cd $PWD

"$@"

sleep 1; kill -INT $strace_pid; sleep 1
/usr/lib/fl_stparse -w $wlog < $slog
touch /var/adm/flists/$pkg
{
  /usr/lib/fl_wrparse -s -r / -p "$pkg" < $wlog
  for x in flists packages dependencies descs cksums md5sums ; do
	echo "$pkg: var/adm/$x/$pkg" ; done
} | cat /var/adm/flists/$pkg - |
	egrep -v '^[^ ]+: (dev|proc|tmp)(/|$)' | sort -u > $flog
cat $flog > /var/adm/flists/$pkg

cd /
egrep -v "^$pkg: var/adm/" var/adm/flists/$pkg | cut -f2- -d' ' | \
 xargs cksum > var/adm/cksums/$pkg
egrep -v "^$pkg: var/adm/" var/adm/flists/$pkg | cut -f2- -d' ' | \
 xargs md5sum > var/adm/md5sums/$pkg

touch var/adm/{dependencies,descs}/$pkg
echo "Package Name and Version: $pkg 0000 mkpkg" > var/adm/packages/$pkg

echo "[ Created package $pkg with" $( wc -l < $flog ) "files. ]"

rm -f $wlog $slog $flog
