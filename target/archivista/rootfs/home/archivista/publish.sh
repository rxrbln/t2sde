#!/bin/bash

ps --no-headers -C publish.sh 
pscount=`ps --no-headers -C publish.sh | wc -l`

# 2 due to foking a sub-process above :-(
if [ $pscount -gt 2 ] ; then
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

cleanup ()
{
	rm -rf live.squash boot root
}

livedir=/home/data/livecd

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

chmod 1777 root/tmp

# approximate output size
d_size=`df -B 1000000 -P /home/data / | tr -s ' ' | cut -d ' ' -f 3 |
        sed '1d ; $!s/$/+\\\/' | bc`
c_size=$(( d_size / 3 )) # a lot of text and binary files, thus more than 2

Xdialog --cancel-label=Cancel --ok-label=Continue --title "Archive publishing" \
--yesno "Based on the current hard disc usage ($d_size MB),
the estimated media utilization will be $c_size MB." 0 0 || exit

unint_xdialog_w_file ()
{
	touch $2
	while true; do
		Xdialog --no-close --no-buttons --title 'Archive publishing' \
		 --infobox "$1\n("`ls -sh $2 | cut -d ' ' -f1`"B done)" 0 0 5000
	done
}

# undo stuff done after installation
cp /home/archivista/.fluxbox/menu{.orig,}

rc apache stop
rc mysql stop

unint_xdialog_w_file "The database archive and the currently running system
are beeing compressed. This process will take quite some time." live.squash &
mksquashfs $dirs ./root/ live.squash -noappend -info -e /home/data/t2-trunk $livedir
kill %- # the Xdialog


unint_xdialog_w_file "The final disc image is beeing created.
This process will take a few minutes." av.iso &

# copy initrd, grub, ...
cp -ar /boot-cd boot

isoname=`date "+%Y%m%d-%H%M"`

# mkisofs, heavily copied out of the T2 sources, since there we add all the
# magic glue automagically ,-)))
mkisofs -q -r -T -J -l -o $isoname -A "Archivista Box" \
        -publisher 'Archivista Box based on the T2 SDE' \
        -b boot/grub/stage2_eltorito -no-emul-boot -boot-load-size 4 -boot-info-table \
        --graft-points live.squash boot=boot

kill %- # the Xdialog

rc mysql start
rc apache start

cleanup

Xdialog --msgbox "Disc image generation completed.
The ISO image filename is $PWD/$isoname." 0 0

