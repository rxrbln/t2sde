#!/bin/bash

if [ "$UID" -ne 0 ]; then
	exec gnomesu -p -t "Enable archiving batch mode" \
	-m "Please enter the system password (root user)^\
in order to enable the archiving batch mode." -c $0
fi

# PATH and co
# . /etc/profile

# include shared code
. ${0%/*}/archiving-setup.in /home/cvs/archivista/jobs/archivingAll.pl

get_days

# disable?
if [ "$tdays" = 0 ]; then
	crontab_remove /home/cvs/archivista/jobs/archivingAll.pl
	exit
fi

get_time

crontab_add /home/cvs/archivista/jobs/archivingAll.pl $h $m $days $PASSWD

