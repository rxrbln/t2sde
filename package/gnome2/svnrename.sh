#!/bin/bash

for x in `(cd $1 ; ls $1.*)` ; do
	svn mv $1/$x $1/${x/$1/$2}
done

read in 
svn commit $1

svn up $1 $2

svn mv $1 $2
svn commit $1 $2

