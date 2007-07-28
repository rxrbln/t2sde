#!/bin/bash

if [ "$UID" -ne 0 ]; then
	exec gnomesu -p -t "Clear slave binlog" \
	-m "Please enter the system password (root user)^\
in order to clear the slave database binlog files." -c $0
fi

# PATH and co
. /etc/profile

mysql -uroot -p$PASSWD -hlocalhost <<-EOT
stop slave;
reset slave;
start start;
EOT

Xdialog --title "" --msgbox "Slave binlog files cleared." 0 0


