#!/bin/bash

if [ "$UID" -ne 0 ]; then
	exec gnomesu -t "Disable mail" \
	-m "Please enter the system password (root user)^\
in order to disable the mail server." -c $0
fi

# PATH and co
. /etc/profile

# disable EXIM at startup
rm -f /etc/rc.d/rc5.d/[KS]??exim

# stop EXIM now
rc exim stop

