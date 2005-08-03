#!/bin/bash

curl ftp://ftp.kde.org/pub/kde/stable/$1/src/ | tr -s ' ' |
cut -d ' ' -f 9 | grep 'tar.bz2' |
while read in; do
	in=${in%.tar.bz2}; pkg=${in%-*}; ver=${in#*-}
	#echo $pkg $ver
	./misc/archive/Update.sh $pkg $ver
done

