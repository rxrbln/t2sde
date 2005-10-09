#!/bin/bash

if [ "$UID" -ne 0 ]; then
	exec gnomesu -t "Setup backup to network location" \
	-m "Please enter the system password (root user)^\
in order to setup the network backup." -c $0
fi

# PATH and co
. /etc/profile

# include shared code
. ${0%/*}/backup-setup.in

get_days

# disable?
if [ "$tdays" = 0 ]; then
	crontab_remove /home/archivista/net-backup.sh
	exit
fi

get_time

# type: cifs / nfs / ...

# server / user / pass / ...

crontab_add /home/archivista/net-backup.sh $h $m $days
rc cron restart

