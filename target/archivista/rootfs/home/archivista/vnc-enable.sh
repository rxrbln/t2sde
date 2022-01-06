#!/bin/bash

if [ "$UID" -ne 0 ]; then
	exec gnomesu -t "Enable VNC" \
	-m "Please enter the current system password (root user)^\
in order to allow graphical remote access (VNC)." -p -c $0
fi

. /etc/profile

# -forever does segfault for me after the first iteration
# later we could loop here ...
nohup x11vnc -passwd $PASSWD > /var/log/vnc.log 2>&1 &

Xdialog --title "" --msgbox "Graphical remote access (VNC) enabled." 0 0

