#!/bin/bash

matched=0

echo "Searching for matching package names ..."

x="`cd package/ ; ls -d */*$1* 2>/dev/null`"

if [ -n "$x" ] ; then
	echo -e "$x\n"
	matched=1
fi

echo "Searching in package descriptions (may take some time) ..."
x="`cd package/ ; grep -iH $1 */*/*.desc | cut -d : -f 1 | uniq`"

if [ -n "$x" ] ; then
        echo -e "$x\n"
	matched=1
fi

[ $matched = 0 ] && echo "No match found ..."

