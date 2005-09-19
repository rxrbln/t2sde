#!/bin/sh

/home/archivista/rescan-scsi-bus.sh
cat /proc/scsi/scsi | Xdialog --no-cancel --log - 20 60
