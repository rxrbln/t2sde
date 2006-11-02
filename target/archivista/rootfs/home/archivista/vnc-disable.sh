#!/bin/bash

if [ "$1"  = "-permanent" ]; then
	shift
	rm -rf /etc/vnc.conf
	Xdialog --title "VNC setup" --msgbox "Graphicial remote access (VNC) is disabled permanently." 0 0
fi

killall x11vnc

if [ -f /etc/vnc.conf ]; then
	if Xdialog --title "VNC setup" --default-no --yesno \
	                   "Disable graphical remote access (VNC) permanently?" \
						 0 0; then
		exec gnomesu -t "VNC setup" \
		             -m "Please enter the system password (root user)^\
in order to disable graphical remote access (VNC) permanently." -c \
		             "$0 -permanent"
	fi
else
	Xdialog --title "VNC setup" --msgbox "Graphicial remote access (VNC) is disabled" 0 0
fi
