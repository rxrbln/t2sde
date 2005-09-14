#!/bin/bash

if [ "$UID" -ne 0 ]; then
	exec gnomesu -t "Disable remote access" \
	-m "Please enter the system password (root user)^\
in order to disable remote access (SSH)." -c $0
fi

# PATH and co
. /etc/profile

rc sshd stop

