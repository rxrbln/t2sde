#!/bin/bash

killall x11vnc
rm -f /etc/vnc.conf

Xdialog --title "VNC setup" --msgbox "Graphicial remote access (VNC) is disabled" 0 0
