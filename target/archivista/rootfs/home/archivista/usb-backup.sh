#!/bin/bash

if [ "$UID" -ne 0 ]; then
        exec gnomesu -t "Perform backup to USB hard-disk" \
        -m "Please enter the system password (root user)^\
in order to immediatly perform a backup to a USB hard-disk." -c $0
fi

# PATH and co
. /etc/profile

# Xdialog and friends
export DISPLAY=:0

# include shared code
. ${0%/*}/usb-backup.in
. ${0%/*}/backup.in

log=`mktemp`
(
	mount_usb /mnt/usb || exit

	rc mysql stop > /dev/null

	# no -a since we can not store user/group on most customer used filesystems ...
	rsync -rt --stats /home/data /mnt/usb/
	error=$?
	[ $error -ne 0 ] && echo "Error $error during rsync run.
Not all files might be transfered."

	umount /mnt/usb

	rc mysql start > /dev/null
) > $log 2>&1

# mail or display?
[ -e /etc/mail.conf ] && . /etc/mail.conf
if [ "$To" ]; then
	sendmail $To <<-EOT
		From: $From
		To: $To
		Subject: USB backup
		$(cat $log)
	EOT
else
	Xdialog --no-cancel --log - 20 60 < $log
fi

rm $log

fixocr
