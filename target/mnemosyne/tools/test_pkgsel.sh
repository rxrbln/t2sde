#!/bin/bash

source ./scripts/functions

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
	
	while read -r rule ; do
		[ -z "$rule" -o "${rule:0:1}" == "#" ] && continue
		line="$( ( echo "$rule" | pkgsel_parse ) \
			| sed -e 's,$1=\".\",print \$5,')"

		buffer=$( gawk "`pkgsel_init`$line" < config/$config/packages | tr '\n' ' ' )
		count=$( echo "$buffer" | wc -w )

		echo -n "rule: $rule "
		if [ $count -gt 0 ]; then
			echo "($buffer)"
		else	
			echo "no matches!"
		fi
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
			echo "ruleset: ${x##*/}" 1>&2
			test_pkgselfile "$x"
		fi
	done
}

for x in ./target/mnemosyne/pkgsel/*; do
	test_pkgsel "$x" ""
done
