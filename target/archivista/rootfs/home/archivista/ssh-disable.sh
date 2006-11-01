#!/bin/bash

if [ "$UID" -ne 0 ]; then
	exec gnomesu -t "Disable remote access" \
	-m "Please enter the system password (root user)^\
in order to disable remote access (SSH)." -c $0
fi

# PATH and co
. /etc/profile

rc sshd stop
rm -rf  /etc/rc.d/rc5.d/S25sshd /etc/rc.d/rc5.d/K75sshd

Xdialog --title "SSH setup" --msgbox "Remote access (SSH) disabled." 0 0
