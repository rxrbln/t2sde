#!/bin/bash

config=default
if [ "$1" == "-cfg" ]; then
	config="$2"; shift
	shift
fi

if [ ! -f config/$config/packages ]; then
	echo "usage: $0 [-cfg <config>]"
	exit 1
fi

function test_pkgselfile() {
	local file="$1"
	local count=
	local buffer=
	
	while read action pattern; do
		[ -z "$action" ] && continue
		case "$action" in
			[#]*)	;;
			X|-)	pattern="$( echo "$pattern" | sed -e 's,\*,[.]*,g' )"
				buffer="$( grep -e " $pattern " config/$config/packages | cut -d' ' -f5 | tr '\n' ' ' )"
				count=$( echo "$buffer" | wc -w )

				if [ $count -gt 0 ]; then
					echo "  $action $pattern ($buffer)"
				else
					echo "  $action $pattern (no matches!)"
				fi
				;;
			*)	echo "    unrecognized '$action'"
				;;
		esac
	done < $file
}

function test_pkgsel() {
	local location="$1"
	local name="${1##*/}"
	local prefix="$2"

	echo "pkgsel: $prefix$name"
	for x in $location/*; do
		if [ -d "$x" ]; then
			test_pkgsel "$x" "$prefix$name"
		else
			echo " -> ${x##*/}"
			test_pkgselfile "$x"
		fi
	done
}

for x in ./target/mnemosyne/pkgsel/*; do
	test_pkgsel "$x" ""
done
