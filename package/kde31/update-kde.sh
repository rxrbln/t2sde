#!/bin/bash

if [ ! "$1" -o ! "$2" ] ; then
	echo "You must specify old and new version ..."
	exit -1
fi

for x in arts* kde* quanta* ; do
	echo "Updateing $x ..."
	sed 	-e s/$1/$2/g \
		-e s,unstable/kde-$1,stable/kde-$2, \
		-e "s/\[D\] [0-9]* /\[D\] 0 /" $x/$x.desc > $x/$x.desc.new
	mv $x/$x.desc.new $x/$x.desc
done

