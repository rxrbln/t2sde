#!/bin/bash

pkg="$1" ; shift
ver="$1" ; shift

if [ -z "$pkg" -o -z "$ver" ] ; then
	echo "Usage: $0 pkg ver"
	exit
fi

rm -f $$.diff
pkg=`echo $pkg | tr [A-Z] [a-z]`

./scripts/Create-PkgUpdPatch $pkg-$ver | tee $$.diff
patch -p1 < $$.diff
rm -f $$.diff

./scripts/Download $pkg
./scripts/Create-CkSumPatch $pkg | patch -p0

