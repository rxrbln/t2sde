#!/bin/bash

if [ "$UID" -ne 0 ]; then
	exec gnomesu -p -t "View Archivista log file" \
	-m "Please enter the system password (root user)^\
in order to view the Archivista log file." -c $0
fi

LOG=/home/data/archivista/av.log

Xdialog --tailbox $LOG 20 100
