#!/bin/bash

pkg="$1" ; shift
ver="$1" ; shift

if [ -z "$pkg" -o -z "$ver" ] ; then
	echo "Usage: $0 pkg ver"
	exit
fi

./scripts/Create-PkgUpdPatch $pkg-$ver | patch -p1
./scripts/Download $pkg
./scripts/Create-CkSumPatch $pkg | patch -p0

