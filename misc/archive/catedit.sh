#!/bin/bash
#
# WARNING: Create backup copies of your files before you use this tool
# for editing the categories of your packages !!!
#
# Usage: sh misc/archive/catedit.sh package/base/*/*.desc
#

item='' title="Choose the package you want to edit"
tmp=$( mktemp )

until
	cmd="dialog ${item:+--default-item} $item --menu '$title' 20 74 13  \
		$( grep '^\[C\]' "$@" | \
		   sed 's,^[^:]*/,,; s,\.[^ ]* , ",; s,$,",;' | tr '\n' ' '
		)"
	eval "$cmd 2> $tmp"
	item="$( cat $tmp )"
	[ -z "$item" ]
do
	for file; do
		[ "${file##*/}" = "$item.desc" ] && break
	done

	dialog --inputbox "Modify categories for $item" 8 70 \
		"$( grep '^\[C\]' "$file" | \
		    sed 's,[^ ]* ,,' | tr '\n' ' ' | sed 's, *$,,'
		)" 2> $tmp
	value="$( cat $tmp )"

	if [ "$value" ]; then 
		grep -v '^\[C\]' "$file" >  $tmp
		echo -e '\n'"[C] $value" >> $tmp
		cat $tmp > $file
		./scripts/Create-DescPatch $item | patch -p1
	fi
done

rm -f $tmp

