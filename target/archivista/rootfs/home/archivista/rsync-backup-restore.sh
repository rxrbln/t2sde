#!/bin/bash

if [ "$UID" -ne 0 ]; then
        exec gnomesu -t "Restore backup from rsync location" \
        -m "Please enter the system password (root user)^\
in order to restore the rsync backup." -c $0
fi

# PATH and co
. /etc/profile

# Xdialog and friends
export DISPLAY=:0

# include shared code
. ${0%/*}/backup.in
. ${0%/*}/rsync-backup.in

log=`mktemp`
(
	# shared function, included on top
	check_config || exit

	rc mysql stop > /dev/null

	mkdir -p /home/data
	# no -a since we can not store user/group on most CIFS shares
	rsync -rt --stats --delete $user@$server:/$dir/data/ /home/data/
	error=$?
	[ $error -ne 0 ] && echo "Error $error during rsync run.
Not all files might be transfered."

	# shared function included on top
	permissions_fixup /home/data

	# potentially fixup naming (case) - just to be sure
	/home/archivista/mysql-case-fixup.sh /home/data/archivista/mysql

	rc mysql start > /dev/null
) > $log 2>&1

Xdialog --no-cancel --log - 20 60 < $log
rm $log

