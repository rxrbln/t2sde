#!/bin/bash
#
# WARNING: Create backup copies of your files before you use this tool
# for editing the categories of your packages !!!
#
# Usage: sh misc/archive/catedit.sh package/base/*/*.desc
#    or: sh misc/archive/catedit.sh -a
#

item='' 
tmp=$( mktemp )
title="Choose the package you want to edit"
btitle='--backtitle "ROCK Linux package category editor"'

if [ $(dialog --version 2>&1| grep -c "0.9") -eq 0 ]; then
    echo "dialog's version at least 0.9 needed"
    exit 1
fi

if [ "$1" = "-a" -o "$1" = "--all" ]; 
then files="$(find package/ -name *.desc | sort -t '/' -k 4)"
else files="$@"
fi

until
	cmd="dialog ${btitle} ${item:+--default-item} $item --cancel-label Quit --menu '$title' 42 120 35  \
		$( grep '^\[C\]' $files | \
		   sed 's,^[^:]*/,,; s,\.[^ ]* , ",; s,$,",;' | tr '\n' ' '
		)"
	eval "$cmd 2> $tmp"
	item="$( cat $tmp )"
	[ -z "$item" ]
do
	for file in $files; do
		[ "${file##*/}" = "$item.desc" ] && break
	done
	dialog 	--cancel-label Back \
		--backtitle ' categories for $item ' \
		--checklist "$(grep "^\[I\]" $file)" 42 80 35 \
	    `for category in $(awk '/^[^# ]/ {print $1}' < Documentation/Developers/PKG-CATEGORIES); do 
		echo -n $category $category
		if [ -n "$(grep "^\[C\].*$category" $file )" ]
		then echo -e " on "
		else echo -e " off "
		fi
	    done` 2> $tmp
	value=$( cat $tmp | tr -d '"' )

	if [ "$value" ]; then 
		cat $file | sed -e "s;\[C\]\(.*\);\[C\] $value;g" > $tmp
		cat $tmp > $file
		./scripts/Create-DescPatch $item | patch -p1
	fi
done

rm -f $tmp
