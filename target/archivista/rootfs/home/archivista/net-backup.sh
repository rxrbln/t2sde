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

# include shared code
. ${0%/*}/net-backup.in

log=`mktemp`
(
	# shared function, included on top
	mount_net /mnt/net || exit
	
	rc mysql stop > /dev/null
	sleep 5 # give mysql some time to shut down fully - can be removed later
		# , when we have a loop waiting for mysql in the init script

	# no -a since we can not store user/group on most CIFS shares
	rsync -rvt /home/data /mnt/net/
	error=$?
	[ $error -ne 0 ] && echo "Error $error during rsync run.
Not all files might be transfered."

	umount /mnt/net

	rc mysql start > /dev/null
) > $log 2>&1

Xdialog --no-cancel --log - 20 60 < $log
rm $log

