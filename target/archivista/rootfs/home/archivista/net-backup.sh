#!/bin/bash

if [ "$UID" -ne 0 ]; then
        exec gnomesu -t "Perform backup to network location" \
        -m "Please enter the system password (root user)^\
in order to immediatly perform a backup to a network share." -c $0
fi

# PATH and co
. /etc/profile

# Xdialog and friends
export DISPLAY=:0

mkdir -p /mnt/net

log=`mktemp`
(
	rc mysql stop > /dev/null

	# mount -t $type $from /mnt/net $options

	# no -a since we can not store user/group on most CIFS shares
	# rsync -rv /home/data /mnt/net/

	# umount /mnt/net

	rc mysql start > /dev/null
) > $log 2>&1

Xdialog --no-cancel --log - 20 60 < $log
rm $log

