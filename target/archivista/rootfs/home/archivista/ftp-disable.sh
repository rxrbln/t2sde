#!/bin/bash

if [ "$UID" -ne 0 ]; then
	exec gnomesu -t "Disable FTP" \
	-m "Please enter the system password (root user)^\
in order to disable the FTP server." -c $0
fi

# PATH and co
. /etc/profile

# disable ftp
sed -i 's,.*\(ftp[[:blank:]].*\)$,# \1,' /etc/inetd.conf 

rc inetd restart

Xdialog --title "" --msgbox "FTP server disabled." 0 0

