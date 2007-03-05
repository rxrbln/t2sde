#!/bin/bash

# Archive specified archvie range or pre-built iso image onto an
# optical disc via wodim (Write Optical DIsk Media).
#
# Data integrity is check by reading the whole set of files back
# and compare the MD5 sum.
#
# Call with:
#               [ isofile ] | [ db range ]
#               e.g.: wodim.sh test-db 123-456
#
# Return codes: 0: success
#               1: no config
#               2: not enough devices with matching media
#               3: no archive does fit on the available disc
#               4: not enough copies written to different devices
#
# Return text:
#               on success the last line: archived range like: 123-200
#
# Copyright (C) 2006 Archivista GmbH
# Copyright (C) 2006 Rene Rebe

iso=
db=
range=
if [ "$1" -a "$2" ]; then
	db="$1"
	range="$2"
	shift 2
elif [ -f "$1" ]; then
	iso="$1"
	shift
else
	echo "$0 [ isofile ] | [ db range ]"
	echo "Where range is numerical such as 123-456"
	exit
fi


# include shared code to send the mail notification
. ${0%/*}/backup.in

# include shared code for speed setup
. ${0%/*}/wodim-setup.in

set -e -x

archive_dir="/home/data/archivista/images" # ... /$db/ARCHxxxx
mkisofsopt="-rJ --graft-points"

# Convert numeric speed variable to the format wodim recognizes.
#
speed2speedopt()
{
	if [ "$speed" = "0" ]; then
		speed=
	else
		speed="speed=$speed"
	fi
}

# Returns the CD/DVD capacity of the disc present in the device in bytes.
#
get_media_size()
{
	local capacity=`dvd+rw-mediainfo $1 | sed -n 's/ *Track Size: *\([^*]*\).*/\1/p'`
	capacity=${capacity:-0} # zero if none at all
	echo $((capacity * 2048)) # as the size is returned in CD sectors
}

# Returns the ISO size of the directories specified in bytes.
#
get_iso_size()
{
	local isosize=`mkisofs $mkisofsopt -q --print-size "$@"`
	isosize=${isosize:-0} 
	echo $((isosize * 2048)) # as the size is returned in CD sectors
}

# Returns the archive folder name for the actual index i
#
archive_name()
{
	printf "ARCH%04d" $1
}

# Log to the user
#
log_file ()
{
	mail_or_display "Write Optical disc media" "$1"
}

log_text ()
{
	local tmp=`mktemp`
	echo "$*" > $tmp
	log_file $tmp ; rm -f $tmp
}

log=`mktemp` # file we accumulate log messages in

# If we are called with just a iso file we just write that
#
if [ "$iso" ]; then
  # get speed
	speed=`wodim_speed $speed`
	speed2speedopt

	devices=
	for dev in /dev/cdrom*; do
		if [ ! -e $dev ]; then
			echo "No CD/DVD device found." >> $log
			continue
		fi

		media_size=`get_media_size $dev`
		if [ $media_size = 0 ]; then
			echo "No media found in $dev." >> $log
			continue
		fi
		devices="$devices $dev"
		devicecount=$(( $devicecount + 1 ))
		break # for now, later search for more
	done
	devices=${devices## }

	if [ -z "$devices" ]; then
		echo "No devices with media available." >> $log
		log_file $log; rm $log
		exit 2
	fi

	dev="$devices"

	Xdialog --no-close --no-buttons --title 'Write Optical disc media' \
	        --infobox "Writing to optical disc in device $dev." 0 0 9999999 &
	wodimerr=0
	wodim dev=$dev $speed "$iso" || wodimerr=$?

	kill %- 2>/dev/null || true # the Xdialog

	if [ $wodimerr != 0 ]; then
		echo -e "Error writing the archive to $dev.\n" >> $log
		wodimerr=4
	else
		echo -e "Successfully written archive to $dev.\n" >> $log
	fi

	log_file $log; rm $log

	exit $wodimerr
fi

# Here we handle the complex archive case
#

# include the configuration
# check configuration constraints
#
[ -e /etc/wodim.conf ] && . /etc/wodim.conf
[ "$speed" ] || speed=0
if [ -z "$copies" -o -z "$format" ]; then
	log_text "No configuration found.
please configure optical disc writing."
	exit 1
fi
speed2speedopt

# no. of writers
devices=
devicecount=0
for dev in /dev/cdrom*; do
	if [ ! -e $dev ]; then
		echo "No CD/DVD device found." >> $log
		continue
	fi

	media_size=`get_media_size $dev`
	if [ $media_size = 0 ]; then
		echo "No media found in $dev." >> $log
		continue
	fi

	case "$format" in
	CD)
		if [ $media_size -gt 1000000000 ]; then
			echo "CD requested but apparently DVD media found in $dev." >> $log
			continue
		fi
		;;
	DVD)
		if [ $media_size -lt 1000000000 ]; then	
			echo "DVD requested but apparently CD media found in $dev." >> $log
			continue
		fi
		;;
	esac
	devices="$devices $dev"
	devicecount=$(( $devicecount + 1 ))
done

# check number of currently available destinations
if [ $devicecount -lt $copies ]; then
	echo "Available devices with matching media ($devicecount) conflicts
with the configured number of copies ($copies)." >> $log
	log_file $log
	exit 2
fi

# now we have a list of devices matching the configuration
# determin the minimal media size available
media_size=
for dev in $devices; do
	ms=`get_media_size $dev`
	[ -z "$media_size" ] && media_size=$ms && continue
	[ $ms -lt $media_size ] && media_size=$ms
done

# finally we know how much space we have for the archive
# check the range accordingly

# requested ranges
req_range_begin=${range/-*/}
req_range_end=${range/*-/}

# range that actually fits
range_begin=$req_range_begin

dir_list=
for i in `seq $req_range_begin $req_range_end`; do
	arc=`archive_name $i`
	dir_list="$dir_list $arc=$archive_dir/$db/output/$arc"
	iso_size=`get_iso_size $dir_list`
	if [ $iso_size -lt $media_size ]; then
		range_end=$i
	else
		break
	fi
done

if [ ! "$range_end" ]; then
	echo "Not even the first archive fits on the disc!" >> $log
	log_file $log ; rm $log
	exit 3
elif [ $range_end != $req_range_end ]; then
	echo "Not all archives fit on the disc, just writing: \
`archive_name $range_begin` - `archive_name $range_end`." >> $log
else
	echo "All archives fit on the disc, writing: \
`archive_name $range_begin` - `archive_name $range_end`" >> $log
fi

# Ok - now we know which archive folders fit on the disc.
# Now comes the hard part of actually writing it, catching errors on the way and
# verifying the data integrity.

files=`mktemp`
md5s=`mktemp`

# Build the final mkisofs "graft point list" as well as the file
# and MD5 sums.

# graft points
dir_list=
for i in `seq $range_begin $range_end`; do
	arc=`archive_name $i`
	dir_list="$dir_list $arc=$archive_dir/$db/output/$arc"
	#date +%N > $archive_dir/$db/output/$arc/rand
	find $archive_dir/$db/output/$arc -type f -printf "$arc/%P\n" >> $files
done

# MD5 sums
(cd $archive_dir/$db/output ; cat $files | sed -e 's,$,\0,' | xargs -r md5sum > $md5s)
rm -f $files

# just a test loop injecting a changed file to test the MD5 check
for i in `seq $range_begin $range_end`; do
	arc=`archive_name $i`
	#date +%N > $archive_dir/$db/output/$arc/rand
done

# final ISO size, we need to pass it to wodim/cdrecord as we create the actual
# FS on-the-fly
#
iso_size=`get_iso_size $dir_list`
iso_size=$((iso_size / 2048)) # CD sectors

echo >> $log # seperator

# for a devices
good_writes=0
for dev in $devices; do
	# create the FS and write it on-the-fly
	wodimerr=0
	mkisofs $mkisofsopt -q $dir_list |
		wodim dev=$dev $speed tsize=${iso_size}s - || wodimerr=$?
	if [ $wodimerr != 0 ]; then
		echo -e "Error writing the archive to $dev.\n" >> $log
	else
		echo -e "Successfully written archive to $dev.\n" >> $log
	fi

	mkdir -p /mnt/wodim
	eject $dev
	mount $dev /mnt/wodim

	# it is a bit of a hickup to catch the error code of md5sum in this case
	pushd /mnt/wodim
	md5sumerr=0
	md5sum --check $md5s > >( grep -v ': OK$' >> $log ) || md5sumerr=$?
	popd

	if [ $md5sumerr != 0 ]; then
		echo -e "Error verifying the data integrity on $dev\n." >> $log
	else
		echo -e "Successfully verified the data integrity on $dev.\n" >> $log
	fi

	# just to join with the background process, so /mnt/wodim is not busy
	sleep 0
	umount /mnt/wodim

	# only on success eject the media
	#
	if [ $md5sumerr = 0 ]; then
		eject $dev
		good_writes=$(( $good_writes + 1 ))
		# stop writing if we reached the configured number of copies
		[ $good_writes = $copies ] && break
	fi
done

if [ $good_writes -lt $copies ]; then
	echo "$copies copy(s) requested but only $good_writes verified copy(s) \
performed!" >> $log
	log_file $log
	rm $md5sums $log
	exit 4
fi

echo "Successfully wrote $good_writes copy(s) to the optical media:
DB: $db Archives: `archive_name $range_begin` - `archive_name $range_end`" >> $log
log_file $log

# for the callee
echo "$range_begin-$range_end"

# clean up
rm -f $md5s $log
