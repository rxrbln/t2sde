#!/bin/bash

if [ -z "$1" ] ; then
	echo "Usage $0 package/files"
	exit
fi

svn diff $* | awk "
	BEGIN { FS=\"[ /\t]\" }
	/+++ / { pkg=\$4 }
	/-\[V\] / { oldver=\$2 }
	/+\[V\] / {
		newver=\$2
		if ( oldver )
		  print \"\t* updated \" pkg \" (\" oldver \" -> \" newver \")\"
		else
		  print \"\t* added \" pkg \" (\" newver \")\"
		oldver=\"\" ; newver=\"\"
	}

" > $$.log

echo "Diff:"
svn diff $*

echo -e "\nLog:"
cat $$.log

echo -en "\nLog ok? "
read in

if [[ "$in" == y* ]] ; then
	svn commit $* --file $$.log
fi

rm $$.log

