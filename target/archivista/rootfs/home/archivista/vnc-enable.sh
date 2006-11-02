#!/bin/bash

# if recalled with the permanent flag as root
if [ "$1" = "-permanent" ]; then
	shift
	PASSWD="$1"; shift

	cat > /etc/vnc.conf <<-EOT
		autostart=1
		passwd="$PASSWD"
EOT

	Xdialog --title "VNC setup" --msgbox \
	        "Graphical remote access (VNC) enabled permanently." 0 0
	exit
fi

PASSWD=`Xdialog --password --stdout --title "VNC setup" \
                --inputbox "Password for
graphical remote access (VNC)" 0 0 $PASSWD` || exit

[ "$PASSWD" ] || exit

. /etc/profile

# if changed, .fluxbox/startup needs an update as well
x11vnc -forever -passwd "$PASSWD" -skip_lockkeys &

if Xdialog --title "VNC setup" --default-no --yesno \
           "Enable graphical remote access (VNC) permanently?" \
           0 0; then
	exec gnomesu -t "VNC setup" \
	             -m "Please enter the system password (root user)^\
in order to enable graphical remote access (VNC) permanently." -c \
	             "$0 -permanent '$PASSWD'"

else
	Xdialog --title "VNC setup" --msgbox \
	        "Graphical remote access (VNC) is enabled" 0 0
fi
