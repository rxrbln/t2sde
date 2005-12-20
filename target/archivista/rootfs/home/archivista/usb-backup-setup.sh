#!/bin/bash

if [ "$UID" -ne 0 ]; then
	exec gnomesu -t "Setup backup to USB hard-disk" \
	-m "Please enter the system password (root user)^\
in order to setup the USB hard-disk backup." -c $0
fi

# PATH and co
. /etc/profile

. ${0%/*}/backup-setup.in /home/archivista/usb-backup.sh

get_days

# disable?
if [ "$tdays" = 0 ]; then
	crontab_remove /home/archivista/usb-backup.sh
	exit
fi

get_time

crontab_add /home/archivista/usb-backup.sh $h $m $days

