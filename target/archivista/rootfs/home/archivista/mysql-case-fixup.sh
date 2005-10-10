#!/bin/bash

# This script is intended to be run on mysql database files imported from
# windows file systems that potentionally screw up the case badly.
#
# Copyright (C) 2005 Archivista GmbH
# Copyright (C) 2005 Rene Rebe

dir="$1" ; shift

if [ ! "$dir" ]; then
	echo "No directory specified."
	exit
fi

find $dir -name "*.[mM][yY][dDiI]" -o -name "*.[fF][rR][mM]" | while read x; do
	#echo "Processing $x"
	file="${x##*/}"
	dir="${x%/$file}"
	#echo $dir -- $file

	fixed_name="`echo $file |
	             sed -e 's/\(.*\)\.\([mM][yY][dDiI]\)/\L\1.\U\2/' \
	                 -e 's/\(.*\)\.\([fF][rR][mM]\)/\L\1.\L\2/'`"

	[ "$file" == "$fixed_name" ] || mv -vf "$dir/$file" "$dir/$fixed_name"
done
