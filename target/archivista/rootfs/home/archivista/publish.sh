#!/bin/bash

# In-system livecd regenerator/repacker that will clone the installed
# system back to an ISO or USB device suiteable for booting and
# installation and even display a progress bar thru Xdialog while doing so.
#
# Copyright (C) 2006 Archivista GmbH
# Copyright (C) 2006 Rene Rebe

tmp=`mktemp`
ps --no-headers -C publish.sh > $tmp

# 2 due to foking a sub-process above :-(
if [ `cat $tmp | wc -l` -gt 1 ] ; then
	Xdialog --no-cancel --title 'Archive publishing' --msgbox \
	        "There is already a publishing process running! Only one instance
can compess the system, try again later." 0 0
	exit
fi

if [ "$UID" -ne 0 ]; then
        exec gnomesu -t "Archive publishing" \
        -m "Please enter the system password (root user)^\
in order to publish the archive." -c $0
fi

# PATH and co
. /etc/profile

# Xdialog and friends
export DISPLAY=:0

set -e

livedir=/home/data/publishing
dbdir=/home/data/archivista/mysql
ocrkey=/home/archivista/.wine/drive_c/Programs/Av5e/av5.con

cleanup ()
{
	rm -rf live.squash boot root
}

# database selection from the user
cd $dbdir
i=0
for x in * ; do
	[ -d "$x" ] || continue
	case "$x" in
		mysql|test) continue ;;
	esac
	dbs[$((i++))]="$i"
	dbs[$((i++))]="$x"
	if [ "$x" = archivista ]; then
		dbs[$((i++))]="on"
	else
		dbs[$((i++))]="off"
	fi
done

while [ -z "$d" ]; do
	d=`Xdialog --stdout --password --no-tags --separate-output \
	   --title 'Archive publishing' --checklist \
	   "Choose the databases to be published." 0 0 3 "${dbs[@]}"` || exit
	[ "$d" ] || Xdialog --no-cancel --title 'Archive publishing' --msgbox \
	                    "You need to select at least one database!" 0 0
done

# generate exclude list and find out if the archivista db is selected
n=$i; i=0
d=" $d " # terminating space
dbexclude=
archivistadb=1
while [ $i -lt $n ]; do
	# selected?
	if [ "${d/ $i /}" != "$d" ]; then
		echo $i selected
	else
		echo $i not seleted
		[ "${dbs[$((i+1))]}" = archivista ] && archivistadb=0
		dbexclude="$dbexclude $dbdir/${dbs[$((i+1))]}"
	fi

  : $(( i += 3 ))
done

echo database exclude: $dbexclude
echo archivista db: $archivistadb

mkdir -p $livedir/root ; cd $livedir
cleanup

# list of top-level dirs
dirs=
for dir in /* ; do
	[ -d $dir ] || continue
	case $dir in
		# do not include the virtual fs or mounted volumes
		/dev|/proc|/sys|/tmp|/mnt|/media)
			mkdir -p root$dir
			continue
			;;
	esac
	dirs="$dirs $dir"
done
echo "dirs: $dirs"

# list of data exclude dirs
dataexclude=
for dir in /home/data/* ; do
	[ -d $dir ] || continue
	case $dir in
		# do include
		/home/data/archivista)
			continue
			;;
	esac
	dataexclude="$dataexclude $dir"
done
echo "dataexclude: $dataexclude"

# final tweaks, include vanilla files, and
# possibly injecting the default archivista db
chmod 1777 root/tmp

if [ $archivistadb = 0 ]; then
	mkdir -p root$dbdir/archivista
	# copy the vanilla files and add the remaining tables
	cp /home/mysql.orig/* root$dbdir/archivista
	for x in $dbdir/archivista/* ; do
		[ -f root$dbdir/archivista/${x##*/} ] ||
		  cp -v $x root$dbdir/archivista/
	done
fi

# approximate output size
# disc usage
set -x
sys_size=`df -B 1000000 -P / | tail -n 1 | tr -s ' ' | cut -d ' ' -f 3`
data_size=`du -B 1000000 -sc $dbdir | tail -n 1 | cut -f 1`

# substract excluded dbs
sub_size=0
if [ "$dbexclude" ]; then
	sub_size=`du -B 1000000 -sc $dbexclude | tail -n 1 | cut -f 1`
fi

# system has a lof of text, thus more than 2
out_size=$(( sys_size / 3 + ( data_size - sub_size ) / 2 ))

Xdialog --cancel-label=Cancel --ok-label=Continue --title "Archive publishing" \
--yesno "Based on the system and data to be archived ($((sys_size + data_size - sub_size)) MB),
the estimated media utilization is $out_size MB." 0 0 || exit

unint_xdialog_w_file ()
{
	touch $2
	while true; do
		Xdialog --no-close --no-buttons --title 'Archive publishing' \
		 --infobox "$1\n(`ls -sh $2 |
  sed 's/ .*// ; s/M/ MB written/ ; s/^0$/creating file list/'`)" 0 0 20000
	done
}

rc apache stop
rc mysql stop

unint_xdialog_w_file "The database archive and the currently running system
are beeing compressed. This process will take quite some time." live.squash &
set -x
mksquashfs $dirs ./root/ live.squash -noappend -info -e \
           /boot-cd $dataexclude $dbexclude $ocrkey \
           /etc/conf/network /home/archivista/.xkb-layout
set +x
kill %- 2>/dev/null || true # the Xdialog

isoname=`date "+av-%Y%m%d-%H%M.iso"`

unint_xdialog_w_file "The final disc image is beeing created.
This process will take a few minutes." $isoname &

# copy initrd, grub, ...
cp -ar /boot-cd boot

# mkisofs, heavily copied out of the T2 sources, since there we add all the
# magic glue automagically ,-)))
mkisofs -q -r -T -J -l -o $isoname -A "Archivista Box" \
        -publisher 'Archivista Box based on the T2 SDE' \
        -b boot/grub/stage2_eltorito -no-emul-boot -boot-load-size 4 -boot-info-table \
        --graft-points live.squash boot=boot
chown archivista:users $isoname

kill %- 2> /dev/null || true # the Xdialog

rc mysql start
rc apache start

cleanup

### ISO generation END ###

Xdialog --title 'Archive publishing' \
           --yesno "Disc image generation completed.
The compressed ISO image is `ls -sh $isoname | sed 's/ .*// ; s/M/ MB /'` \
and named
$PWD/$isoname.
Do you want to copy the archive to an USB device?" 0 0 || exit

### USB device install BEGIN ###

# prevent hotplug backup
usblog=`mktemp`
touch /tmp/hot.lock

# wait for a stick injection
usbdev=

get_device_list () {
# from livecd init, best kept in sync ,-) -ReneR
	for x in /sys/block/*/device; do
		case "`ls -l $x`" in
	     */usb*|*/ieee1394) : ;;
	     *) continue ;;
		esac
		x=${x%/device}; x=/dev/${x#/sys/block/}
		echo -n " $x "
		done
}

Xdialog --ok-label Cancel --title "Archive publishing" \
        --msgbox "Waiting for USB device. Please insert
the device you want to use." 0 0 &

initial_list="`get_device_list`"
dev=
while [ -z "$dev" ] && jobs %- ; do # while no device and not cancel
	sleep 1
	# get a new list
	new_list="`get_device_list`"

	# is there a new one?
	new_one=0
	for d in $new_list; do
		if [ "${initial_list/ $d /}" = "$initial_list" ]; then
			new_one=1
			[ -e "$d" ] && dev=$d	# u/dev device node exits?
		fi
	done
	if [ $new_one -eq 0 ]; then
		# update the list, so pulling a device and inserting one works (both sda)
  	initial_list="$new_list"
	fi
done
usbdev=$dev


kill %- 2> /dev/null || true # the Xdialog
[ "$usbdev" ] || exit
sleep 1 # work around to let the above job disappear ...

# convert it, multi threaded displaying
Xdialog --no-close --no-buttons --title "Copying archive to USB device" \
        --logbox $usblog 25 80 &

echo -e "Copying archive to USB device ($usbdev):\n" > $usblog
${0%/*}/iso2stick.sh ./$isoname $usbdev >> $usblog 2>&1 &

if ! wait %2 ; then  # wait for the iso2stick
	Xdialog --title "Archive publishing" --msgbox \
	        "There was an error copying the archive." 0 0
	kill %- 2> /dev/null # the Xdialog
	exit
fi
kill %- 2> /dev/null # the Xdialog

rm /tmp/hot.lock $usblog

### USB device install END ###

Xdialog --no-cancel --title "Archive publishing" \
        --msgbox "Archive copied to the USB device." 0 0

if Xdialog --default-no --title "Archive publishing" \
           --yesno "Delete published archive now?" 0 0; then
	rm -v ./$isoname
fi

