#!/bin/bash

if [ "$UID" -ne 0 ]; then
	exec gnomesu -t "Setup backup" \
	-m "Please enter the system password (root user)^\
in order to setup the backup." -c $0
fi

# PATH and co
. /etc/profile

# include shared code
. ${0%/*}/backup-setup.in /home/archivista/backup.sh

get_days

# disable?
if [ "$tdays" = 0 ]; then
	crontab_remove /home/archivista/backup.sh
	exit
fi

get_time

crontab_add /home/archivista/backup.sh $h $m $days

