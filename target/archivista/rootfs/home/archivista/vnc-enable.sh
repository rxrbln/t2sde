#!/bin/bash

PASSWD=`Xdialog --password --stdout --title "VNC setup" \
                --inputbox "Password for
graphical remote access (VNC)" 0 0 $PASSWD` || exit

if [ -z "$PASSWD" ]; then 
  exit
fi

. /etc/profile

# if changed, .fluxbox/startup needs an update as well
x11vnc -forever -passwd "$PASSWD" -skip_lockkeys &

if Xdialog --title "VNC setup" --default-no --yesno \
           "Enable graphical remote access (VNC) permanently?" \
           0 0; then
	cat > /etc/vnc.conf <<-EOT
		autostart=1
		passwd="$PASSWD"
EOT

	Xdialog --title "VNC setup" --msgbox \
	        "Graphical remote access (VNC) enabled permanently." 0 0
else
	rm -f /etc/vnc.conf
	Xdialog --title "VNC setup" --msgbox \
	        "Graphical remote access (VNC) is enabled" 0 0
fi
