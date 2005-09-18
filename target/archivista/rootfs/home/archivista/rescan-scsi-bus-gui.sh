#!/bin/sh

/home/archivista/rescan-scsi-bus-gui.sh
cat /proc/scsi/scsi | Xdialog --no-cancel --log - 20 60
