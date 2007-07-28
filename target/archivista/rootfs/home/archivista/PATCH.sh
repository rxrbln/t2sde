#!/bin/sh

# (c) 2006-06-23 Archivista GmbH, Tobias Binz
# Script to patch all files in a folder (if *.patch files ara available)

for i in *.patch; do
	if [ -f $(ls "$i" | sed -e 's/.patch//') ];then
		ORIGINAL=$(ls "$i" | sed -e 's/.patch//') 
		patch "$ORIGINAL" "$i"
	else 
		echo "No original file $i found!"
		exit
	fi
done
