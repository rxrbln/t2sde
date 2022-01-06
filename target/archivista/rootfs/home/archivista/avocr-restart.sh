#!/bin/bash

if [ "$UID" -ne 0 ]; then
	exec gnomesu -t "Restart OCR server" \
        -m "Please enter the system password (root user)^\
in order to restart the OCR server." -c $0
fi

# PATH and co
. /etc/profile

killall wine-preloader
cd  /home/archivista/.wine/drive_c/Programs/Av5e
cat AV5AUTO.LOG >>/home/data/archivista/images/AV5AUTO.LOG
rm -rf AV5AUTO.{WRK,STP,END,LOG}

Xdialog --title "" --msgbox "OCR server restarted." 0 0

