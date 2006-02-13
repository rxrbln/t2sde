#!/bin/bash

if [ "$UID" -ne 0 ]; then
	exec gnomesu -p -t "Start archiving job right now" \
	-m "Please enter the system password (root user)^\
in order to start the archiving job right now." -c $0
fi

# PATH and co
# . /etc/profile

/home/cvs/archivista/jobs/archivingNow.pl $PASSWD
