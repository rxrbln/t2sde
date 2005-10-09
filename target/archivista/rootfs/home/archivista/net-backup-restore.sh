#!/bin/bash

if [ "$UID" -ne 0 ]; then
        exec gnomesu -t "Restore backup from network location" \
        -m "Please enter the system password (root user)^\
in order to restore the network backup." -c $0
fi

mkdir -p /mnt/net

log=`mktemp`
(
	rc mysql stop
	mkdir -p /home/data
	rm -rf /home/data/*
	cd /home/data

	# mount -t $type $from /mnt/net $options

	# no -a since we can not store user/group on most CIFS shares
	# rsync -rv /home/data /mnt/net/

	# umount /mnt/net

	rc mysql start
) > $log 2>&1

Xdialog --no-cancel --log - 20 60 < $log
rm $log

