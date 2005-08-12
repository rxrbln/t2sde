#!/bin/bash

if [ "$UID" -ne 0 ]; then
	exec gnomesu -t "Database master mode" \
	-m "Please enter the system password (root user)^\
in order to bring the database into master mode." -c $0
fi

# PATH and co
. /etc/profile

# TODO: add replication user to mysql

sed -i -e "s/.*log-bin$/log-bin/" \
       -e "s/.*max-binlog-size.*/max-binlog-size = 300M/" /etc/my.cnf

rc mysql restart

