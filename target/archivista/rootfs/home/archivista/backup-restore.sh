#!/bin/bash

if [ "$UID" -ne 0 ]; then
        exec gnomesu -t "Restore backup" \
        -m "Please enter the system password (root user)^\
in order to restore the backup." -c $0
fi

(
	rc mysql stop
	mkdir -p /home/data
	rm -rf /home/data/*
	cd /home/data
        mt -f /dev/nst0 asf 1
	flexbackup -extract
	rc mysql start
) | Xdialog --no-cancel --log - 20 60

