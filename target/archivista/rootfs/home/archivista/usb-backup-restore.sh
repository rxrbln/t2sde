#!/bin/bash

if [ "$UID" -ne 0 ]; then
        exec gnomesu -t "Restore backup from USB hard-disk" \
        -m "Please enter the system password (root user)^\
in order to restore the USB hard-disk backup." -c $0
fi

# PATH and co
. /etc/profile

# Xdialog and friends
export DISPLAY=:0

# include shared code
. ${0%/*}/backup.in
. ${0%/*}/usb-backup.in

log=`mktemp`
(
	# shared function, included on top
	mount_usb /mnt/usb || exit

	rc mysql stop > /dev/null

	mkdir -p /home/data

	# no -a since we can not store user/group on most CIFS shares
	rsync -rvt --delete /mnt/usb/data/ /home/data/

	# shared function, included on top
	permissions_fixup /mnt/data

	# potentially fixup naming (case) - just to be sure
	/home/archivista/mysql-case-fixup.sh /home/data/archivista/mysql

	umount /mnt/usb

	rc mysql start > /dev/null
) # > $log 2>&1

Xdialog --no-cancel --log - 20 60 < $log
rm $log

