#!/bin/bash

pkg="$1" ; shift
ver="$1" ; shift

if [ -z "$pkg" -o -z "$ver" ] ; then
	echo "Usage: $0 pkg ver"
	exit
fi

rm -f $$.diff
pkg=`echo $pkg | tr [A-Z] [a-z]`

if [ -d package/*/$pkg ]; then
	./scripts/Create-PkgUpdPatch $pkg-$ver | tee $$.diff
	patch -p1 < $$.diff
	rm -f $$.diff

	./scripts/Download $pkg
	./scripts/Create-CkSumPatch $pkg | patch -p0
else
	echo "ERROR: package $pkg doesn't exist"
	echo package/*/*$pkg*/ | tr ' ' '\n' | grep -v '*'
fi

