#!/bin/sh
# --- T2-COPYRIGHT-BEGIN ---
# t2/misc/archive/findorphans.sh
# Copyright (C) 2006 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

config=default
root=
folders=

usage() {
	echo "usage: $0 [-cfg <config>|-root <root>|-system]"
}

while [ $# -gt 0 ]; do
	case "$1" in
	-cfg)	config="$2"
		root= ; shift ;;
	-root)	root="$2"; shift ;;
	-system) root=/ ;;
	-just)	shift; folders="$@"; break ;;
	-help)	usage; exit 0 ;;
	*)	echo "ERROR: unknown argument '$1'"
		usage; exit 1 ;;
	esac
	shift
done

if [ -z "$root" ]; then
	if [ ! -f config/$config/config ]; then
		echo "ERROR: '$config' is not a valid config"
		exit 2
	else
		root="build/`grep ' SDECFG_ID=' \
			config/$config/config | cut -d\' -f2`"
	fi
fi

if [ ! -d "$root/var/adm/flists" ]; then
	echo "ERROR: '$root' is not a valid T2 box/sandbox root"
	exit 3
fi	

flists=$( cd "$root"; echo var/adm/flists/* )
realroot=$( cd "$root"; pwd )

findroot=
for f in $folders; do
	findroot="$findroot $realroot/${f#/}"
done
[ "$findroot" ] || findroot="$realroot"

pushd "$realroot" > /dev/null
find $findroot -mindepth 1 \
	\( -path "$realroot/TOOLCHAIN" -o \
	   -path "$realroot/proc" -o \
	   -path "$realroot/tmp" -o \
	   -path '*/.svn' \) -prune \
	-o -print | sed -e "s,^$realroot/,," |
	while read file; do
		if ! grep -q -l "^[^ ]*: ${file}\$" $flists; then
			echo "$file"
		fi
done
popd > /dev/null
