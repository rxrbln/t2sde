#!/bin/sh

if [ "$1" == "-list" ]; then
	grep '^\[M\]' package/*/*/*.desc | cut -d' ' -f2- | sort -u | \
		while read maintainer; do
			echo -n "-> '$maintainer' ..."
			count=$( grep -l "^\[M\] $maintainer\$" package/*/*/*.desc | wc -l )
			echo "($count)"
		done

elif [ $# -eq 2 ]; then
	echo "changing '$1' to '$2'..."
	for x in `grep -l "^\[M\] $1[ \t]*$" package/*/*/*.desc`; do
		echo "-> $x"
		sed -i -e "s,^\[M\] $1[ \t]*\$,[M] $2," $x
	done
else
	echo "Usage: $0 -list"
	echo "       $0 <old> <new>"
fi
