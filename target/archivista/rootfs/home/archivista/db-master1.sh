#!/bin/bash

if [ "$UID" -ne 0 ]; then
	exec gnomesu -p -t "Clear master binlog" \
	-m "Please enter the system password (root user)^\
in order to clear the master database binlog files." -c $0
fi

# PATH and co
. /etc/profile

mysql -uroot -p$PASSWD -hlocalhost <<-EOT
reset master;
EOT

Xdialog --title "" --msgbox "Master binlog files cleared." 0 0


