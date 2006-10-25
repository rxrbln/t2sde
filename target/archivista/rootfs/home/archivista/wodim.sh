#!/bin/bash

# Archive specified archvie range or pre-built iso image onto an
# optical disc via wodim (Write Optical DIsk Media).
#
# Data integrity is check by reading the whole set of files back
# and compare the MD5 sum.
#
# Copyright (C) 2006 Archivista GmbH
# Copyright (C) 2006 Rene Rebe

if [ -z "$1" ]; then
	echo "$0 dir | range"
	exit
fi

# include shared code to send the mail notification
. ${0%/*}/backup.in

set -e -x

archive_dir="/home/data/t2-trunk/target/archivista/rootfs/home/archivista/archive"
mkisofsopt="-rJ --graft-points"

# Returns the CD/DVD capacity of the disc present in the device in bytes.
#
get_media_size()
{
	local capacity=`dvd+rw-mediainfo $1 | sed -n 's/READ CAPACITY.*=//p'`
	echo ${capacity-0} # zero if none at all
}

# Returns the ISO size of the directories specified in bytes.
#
get_iso_size()
{
	local isosize=`mkisofs $mkisofsopt -q --print-size "$@"`
	isosize=${isosize-0} 
	echo $((isosize * 2048)) # as the size is returned in CD sectors
}

media_size=`get_media_size /dev/sr0` # TODO

# requested ranges
req_range_begin=${1/-*/}
req_range_end=${1/*-/}

# range that actually fits
range_begin=$req_range_begin

dir_list=
for i in `seq $req_range_begin $req_range_end`; do
	dir_list="$dir_list $i=$archive_dir/$i"
	iso_size=`get_iso_size $dir_list`
	if [ $iso_size -lt $media_size ]; then
		range_end=$i
	else
		break
	fi
done

if [ ! "$range_end" ]; then
	echo "Not even the first archive does fit on disc!"
elif [ $range_end != $req_range_end ]; then
	echo "Not all archives fit on the disc, just writing: $range_begin - $range_end."
else
	echo "All archives fit on the disc, writing: $range_begin - $range_end"
fi

# Ok - now we know which archive folders fit on the disc.
# The hard part of actually writing it, catching errors on the way and
# verifying the data integrity.

files=`mktemp`
md5s=`mktemp`

# Build the final mkisofs "graft point list" as well as the file
# and MD5 list.

# graft points
dir_list=
for i in `seq $range_begin $range_end`; do
	dir_list="$dir_list $i=$archive_dir/$i"
	#date +%N > $archive_dir/$i/rand
	find $archive_dir/$i -type f -printf "$i/%P\n" >> $files
done

# MD5 sums
(cd $archive_dir ; cat $files | sed -e 's,$,\0,' | xargs -r md5sum > $md5s)
rm -f $files

# TODO: remove this test check
for i in `seq $range_begin $range_end`; do
	#date +%N > $archive_dir/$i/rand
	:
done

iso_size=`get_iso_size $dir_list`
iso_size=$((iso_size / 2048)) # CD sectors

mkisofs $mkisofsopt -q $dir_list | wodim dev=/dev/sr0 tsize=${iso_size}s -
wodimerr=$?

mkdir -p /mnt/wodim

mount /dev/sr0 /mnt/wodim

# it is a bit of a hickup to catch the error code of md5sum  here
pushd /mnt/wodim
md5sumerr=0
md5sum --check $md5s > >( grep -v ': OK$' ) || md5sumerr=$?
popd
sleep 0

echo CODE: $md5sumerr
umount /mnt/wodim

rm -f $md5s

# only on success eject the media
#
if [ $md5sumerr = 0 ]; then
	 eject /dev/sr0
fi
