#!/bin/bash

if [ "$UID" -ne 0 ]; then
	exec gnomesu -t "Disable PDF printing" \
	-m "Please enter the system password (root user)^\
in order to disable PDF printing." -c $0
fi

# PATH and co
. /etc/profile

# remove the printer from CUPS
lpadmin -x archivista

# disable CUPS at startup
rm -f /etc/rc.d/rc5.d/[KS]??cups

# stop CUPS now
rc cups stop

