#!/bin/bash
#
# WARNING: Create backup copies of your files before you use this tool
# for editing the categories of your packages !!!
#
# Usage: sh misc/archive/catedit.sh package/base/*/*.desc
#    or: sh misc/archive/catedit.sh -a
#

set -e

item='' 
tmp=$( mktemp )

if [ $(dialog --version 2>&1| grep -c "0.9") -eq 0 ]; then
    echo "dialog's version at least 0.9 needed"
    exit 1
fi

if [ "$1" = "-a" -o "$1" = "--all" ]
then files="$(find package/ -name *.desc | sort -t '/' -k 4)"
else files="$@"
fi

until
	pkglst=$(grep '^\[C\]' $files | sed -e 's,^[^:]*/,,;' \
	         -e 's,\.[^ ]* , ",;' -e 's,$,",;' | sed -e 's, "$,",' \
	         | tr '\n' ' ' )

	eval dialog --backtitle \"ROCK Linux package category editor\" \
	       ${item:+--default-item} $item --cancel-label \
	       Quit --menu \"Choose the package you want to edit\" \
	       42 120 35 $pkglst 2> $tmp

	item="$( cat $tmp )"
	cat $tmp
	[ -z "$item" ]
do
	for file in $files; do
		[[ $file = */$item.desc ]] && break
	done
	
	(for category in $(awk '/^[^# ]/ {print $1}' < Documentation/Developers/PKG-CATEGORIES); do
		echo -n $category $category
		if [ -n "$(grep "^\[C\].*$category" $file )" ]
		then echo -e " on "
		else echo -e " off "
		fi
	done ) > $tmp

	dialog --cancel-label Back --backtitle " categories for $item " \
	       --checklist "$(grep '^\[I\]' $file | sed 's/\[I\] //' )" \
	       42 80 35 $(cat $tmp) 2> $tmp
	value=$( cat $tmp | sed -e 's/"//g' -e 's/ $//' )

	if [ "$value" ] ; then 
		cat $file | sed "s,^\[C\] .*,\[C\] $value,g" > $tmp
		cat $tmp > $file
		#grep -v '^\[C\]' "$file" >  $tmp
		#echo -e '\n'"[C] $value" >> $tmp	
		#./scripts/Create-DescPatch $item | patch -p1
	fi
done

rm -f $tmp
