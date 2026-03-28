#!/bin/sh
# --- T2-COPYRIGHT-BEGIN ---
# t2/misc/archive/copypackage.sh
# Copyright (C) 2006 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

show_usage() {
	echo "Usage: $0 <source> <target> <pkg> ..."
	exit 1
}

cppkg() {
	local from="$1" to="$2" pkg="$3"
	if [ -f $from/var/adm/flists/$pkg ]; then
		if [ -f $to/var/adm/flists/$pkg ]; then
			echo "$pkg: already present at target ($to)"
			cut -d' ' -f2- $to/var/adm/flists/$pkg | while read -r f; do
				if [ "$f" == var/adm/flists/$pkg ]; then
					true
				elif [ ! -d "$to/$f" ]; then
					rm -vf "$to/$f"
				fi
			done
			rm -vf $to/var/adm/logs/*-$pkg.{err,out,log} 2> /dev/null
		fi

		echo "$pkg: $from -> $to"
		cut -d' ' -f2- $from/var/adm/flists/$pkg | 
			tar -C "$from/" --ignore-failed-read --no-recursion -T - -c -O | 
			tar -C "$to" --same-owner --preserve -xvf -
		cp -v $from/var/adm/logs/*-$pkg.{err,out,log} $to/var/adm/logs/ 2> /dev/null
	else
		echo "$pkg: package not found at source ($from)"
	fi
}

source="$1"; shift
target="$1"; shift 

if [ $# -gt 0 -a -f ./config/$source/config -a -f ./config/$target/config -a "$source" != "$target" ]; then
	SDECFG_ID=
	eval `grep SDECFG_ID= ./config/$source/config`
	if [ -d "./build/$SDECFG_ID/var/adm/flists/" ]; then
		source=./build/$SDECFG_ID

		SDECFG_ID=
		eval `grep SDECFG_ID= ./config/$target/config`
		if [ -d "./build/$SDECFG_ID/var/adm/flists/" ]; then
			target=./build/$SDECFG_ID

			for x in $*; do
				cppkg "$source" "$target" "$x"
			done
		else
			echo "'$target' is not a valid config" 1>&2
			show_usage
		fi
	else
		echo "'$source' is not a valid config" 1>&2
		show_usage
	fi
else
	echo "Invalid Arguments" 1>&2
	show_usage
fi
