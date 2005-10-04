#!/bin/bash

if [ "$UID" -ne 0 ]; then
	exec gnomesu -t "Disable PDF printing" \
	-m "Please enter the system password (root user)^\
in order to disable PDF printing." -c $0
fi

# PATH and co
. /etc/profile

# remove the printer from CUPS
lpadmin -x virtualpdf

# disable CUPS at startup
rm -f /etc/rc.d/rc5.d/S30cups /etc/rc.d/rc5.d/K70cups

# stop CUPS now
rc cups stop

