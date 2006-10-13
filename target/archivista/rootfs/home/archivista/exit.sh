#!/bin/bash

# PATH and co
. /etc/profile

# Xdialog and friends
export DISPLAY=:0

if [ "$UID" -ne 0 ]; then
        exec gnomesu -t "Exit" \
        -m "Please enter the system password (root user)^\
in order to exit." -c $0
fi

error=0
if [ -e /home/archivista/.wine/drive_c/Programs/Av5e/AV5AUTO.WRK ]; then
  Xdialog --title "" --yesno "There are batch jobs running. \
  Do you want to stop them?" 0 0 || exit
  Xdialog --title "Stop ArchivistaBox" --no-buttons --infobox "Please wait some seconds..." 0 0 20000 &
  /usr/bin/perl /home/cvs/archivista/jobs/stopJobs.pl 20
  error=$?
fi

if [ $error -eq 0 ]; then
  mode=`Xdialog --title 'Exit' --stdout --no-tags --separator ' ' --radiolist \
	"Choose one option" 0 0 3 \
	1 'Shutdown' off \
	2 'Reboot'   off` || exit
  if [ $mode -eq 1 ];then
    shutdown -h now
  elif  [ $mode -eq 2 ];then
    reboot
  fi
else
  Xdialog --msgbox "Jobs can't be stopped. Please try again later." 0 0
fi

