#!/bin/bash

if [ "$UID" -ne 0 ]; then
	exec gnomesu -p -t "Database slave -> master mode" \
	-m "Please enter the system password (root user)^\
in order to bring the database from slave into master mode." \
	-c $0
fi

# PATH and co
. /etc/profile

# stop slave mode
mysql -uroot -p$PASSWD -hlocalhost <<-EOT
SLAVE STOP;
RESET SLAVE;
EOT

rc mysql stop

# configure normal, master mode
sed -i -e "s/.*server-id.*/server-id = 1/" \
       -e "s/.*\(master-.*\)/# \1/" /etc/my.cnf

rc mysql start

