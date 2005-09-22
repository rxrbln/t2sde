#!/bin/bash

if [ "$UID" -ne 0 ]; then
	exec gnomesu -t "Database slave -> normal mode" \
	-m "Please enter the system password (root user)^\
in order to bring the database from slave into normal mode." \
	-c $0
fi

# PATH and co
. /etc/profile

rc mysql stop

# bring into normal mode
sed -i -e "s/.*server-id.*/server-id = 1/" \
       -e "s/.*log-bin$/#log-bin/" /etc/my.cnf

rc mysql start

