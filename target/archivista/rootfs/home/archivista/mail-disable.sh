#!/bin/bash

if [ "$UID" -ne 0 ]; then
	exec gnomesu -t "Disable incoming mail" \
	-m "Please enter the system password (root user)^\
in order to disable the incoming mail server." -c $0
fi

# PATH and co
. /etc/profile

# close for the public
sed -i 's/#[ ]*\(.*local_interfaces \)/\1/' /etc/exim/configure

# restart EXIM now
rc exim restart

