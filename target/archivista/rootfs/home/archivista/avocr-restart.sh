#!/bin/bash

if [ "$UID" -ne 0 ]; then
	exec gnomesu -t "Restart OCR server" \
        -m "Please enter the system password (root user)^\
in order to restart the OCR server." -c $0
fi

# PATH and co
. /etc/profile

/bin/su - archivista -c wineboot
cd  /home/archivista/.wine/drive_c/Programs/Av5e
cat AV5AUTO.LOG >>/home/data/archivista/images/AV5AUTO.LOG
rm -rf AV5AUTO.{WRK,STP,END,LOG}
/usr/bin/perl /home/cvs/archivista/jobs/initpdf.pl

Xdialog --title "" --msgbox "OCR server restarted." 0 0

