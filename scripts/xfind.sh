#!/bin/bash

# Subversion has really big ".svn" subdirs. This has much better performance
# than the "find ... ! -path '*/.svn*' ! -path '*/CVS*' ..." used earlier
# in various places.

tmp1=`mktemp` tmp2=`mktemp`

while [ "$#" -gt 0 ]
do
	[ -z "${1##[-(]*}" ] && break
	echo $1 >> $tmp1
	shift
done

while ! cmp -s $tmp1 $tmp2
do
	cat $tmp1 > $tmp2
	find $( cat $tmp2 ) -maxdepth 1 -type d \
		! -name 'CVS' ! -name '.svn' | sort -u > $tmp1
done

find $( cat $tmp2 ) -mindepth 1 -maxdepth 1 \
	! -name 'CVS' ! -name '.svn' "$@"

rm -f $tmp1 $tmp2

