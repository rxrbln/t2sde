#!/bin/sh

incdir=${1:-/usr/include}
incdir=${incdir%/}

echo 'Created by architecture/share/copy-inc.sh.' > README

find . -type f -name '*.h' | xargs rm -fv
find . -type d -empty | xargs rmdir -p 2> /dev/null

files="stdio.h string.h stdlib.h unistd.h errno.h limits.h fcntl.h
       signal.h sys/socket.h sys/un.h sys/ucontext.h sys/syslog.h"

for file in $files ; do
	mkdir -p `dirname $file`
	[ -f "$file" ] || cp -v "$incdir/$file" "$file"
	egrep '^# *(include|define.*_H)' < $file > temp.h
	cpp -w -D_GNU_SOURCE -M -I "$incdir" temp.h |
	tr ' ' '\n' | grep "^$incdir/" | while read fn ; do
		xfn=${fn#$incdir/}
		mkdir -p `dirname $xfn`
		[ -f "$xfn" ] || cp -v $fn $xfn
	done
done

rm -f temp.h

