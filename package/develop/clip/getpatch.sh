#!/bin/sh
# --- T2-COPYRIGHT-BEGIN ---
# t2/package/*/clip/getpatch.sh
# Copyright (C) 2004 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

tempfile=clip-patch.tar.gz.$$
#location=ftp://ftp.linux.ru.net/mirrors/clip
location=ftp://www.cis.by/pub/clip/pub/clip
#location=ftp://ftp.itk.ru/pub/clip

echo "get: $location/patch.tgz"
if [ -f patch.tgz ]; then
	mv patch.tgz $tempfile
else
#	wget $location/patch.tgz -O $tempfile
	curl $location/patch.tgz -o $tempfile
	if [ $? -ne 0 ]; then
		rm -f $tempfile
		exit
	fi
fi

release=$( tar zOxf $tempfile ./clip-prg/clip/release_version 2> /dev/null )
[ -z "$release" ] && release=$( grep -e '^\[V\]' clip.desc | cut -d' ' -f2- | cut -d'-' -f1)
seqno=$( tar zOxf $tempfile ./clip-prg/clip/seq_no.txt 2> /dev/null )

echo "$release-$seqno"

if [ -n "$release" -a -n "$seqno" ]; then
	archdir=../../../download/mirror/c/
	filename=clip-patch-$release-$seqno.tbz2

	if [ -f $archdir/$filename ]; then
		echo "INFO: $filename already grabbed"
	else
		zcat ./$tempfile | bzip2 - > $archdir/$filename
		echo "INFO: $filename catched!"
	fi
	rm -f ./$tempfile
	( cd ../../..; sh misc/archive/Update.sh clip $release-$seqno )
else
	echo "ERROR: take a look into ./$tempfile"
fi
