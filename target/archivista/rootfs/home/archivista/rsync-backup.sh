#!/bin/bash

if [ "$UID" -ne 0 ]; then
        exec gnomesu -t "Perform backup to rsync location" \
        -m "Please enter the system password (root user)^\
in order to immediatly perform a backup to a rsync server." -c $0
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
	check_config || exit
	rc mysql stop > /dev/null

	# no -a since we can not store user/group on most Windows servers
	rsync -rt --stats /home/data $user@$server:$dir/
	error=$?
	[ $error -ne 0 ] && echo "Error $error during rsync run.
Not all files might be transfered."

	rc mysql start > /dev/null
) > $log 2>&1

mail_or_display "Rsync backup" $log ; rm $log

fixocr
