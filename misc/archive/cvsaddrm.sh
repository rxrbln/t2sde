#!/bin/sh

tmp1=`mktemp`
tmp2=`mktemp`

find -type d -name CVS | while read dirname ; do
	echo ${dirname%/*}
	awk -F "/" '$1 == "" && $3 !~ /^-/ {
		print "'"${dirname%/*}"'/" $2; }' < $dirname/Entries
done | sed 's,./,,' | sort > $tmp1

find | grep -v '/CVS' | grep -v '/\.$' | sed 's,./,,' | sort > $tmp2

diff -u0 $tmp1 $tmp2 | grep '^[-+][A-Za-z]' | \
	egrep -xv '\+Documentation/(FAQ|LSM)' | \
	sed 's,^-,cvs remove ,; s,^+,cvs add    ,'

rm -f $tmp1 $tmp2

