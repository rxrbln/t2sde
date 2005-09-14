#!/bin/bash

if [ "$UID" -ne 0 ]; then
	exec gnomesu -t "Pause database for slave setup" \
	-m "Please enter the system password (root user)^\
in order to pause the master database for slave setup." \
	-c $0
fi

# PATH and co
. /etc/profile

rc mysql stop

Xdialog --ok-label=Restart --msgbox "The database is paused, the
slave can be synced, now." 10 38

rc mysql start

