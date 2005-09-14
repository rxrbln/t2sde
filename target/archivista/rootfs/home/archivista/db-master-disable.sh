#!/bin/bash

if [ "$UID" -ne 0 ]; then
	exec gnomesu -t "Disable database master mode" \
	-m "Please enter the system password (root user)^\
in order to disable the database master mode." -c $0
fi

# PATH and co
. /etc/profile

sed -i -e "s/^log-bin$/# log-bin/" \
       -e "s/^max-binlog-size.*/# max-binlog-size = 300M/" /etc/my.cnf

rc mysql restart

