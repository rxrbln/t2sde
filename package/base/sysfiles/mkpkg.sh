#!/bin/bash

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

