#!/bin/sh
tempfile=clip-patch.tar.gz.$$
#location=ftp://ftp.linux.ru.net/mirrors/clip
location=ftp://ftp.itk.ru/pub/clip/

echo "get: $location/patch.tgz"
if [ -f patch.tgz ]; then
	mv patch.tgz $tempfile
else
	curl -v $location/patch.tgz -o $tempfile
	if [ $? -ne 0 ]; then
		rm -f $tempfile
		exit
	fi
fi

release=$( tar zOxf $tempfile ./clip-prg/clip/release_version )
[ -z "$release" ] && release=$( grep -e '^\[V\]' clip.desc | cut -d' ' -f2- | cut -d'-' -f1)
seqno=$( tar zOxf $tempfile ./clip-prg/clip/seq_no.txt )

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
else
	echo "ERROR: take a look into ./$tempfile"
fi
