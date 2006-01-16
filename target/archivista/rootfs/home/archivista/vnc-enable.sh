#!/bin/bash

PASSWD=`Xdialog --password --stdout --inputbox "Password for
graphical remote access (VNC)" 0 0 $PASSWD` || exit

if [ -z "$PASSWD" ]; then 
  exit
fi

. /etc/profile

x11vnc -forever -passwd $PASSWD &


Xdialog --stdout --msgbox "Graphical remote access (VNC) is enabled" 0 0


