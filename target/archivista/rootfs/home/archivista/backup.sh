#!/bin/bash

if [ $UID -ne 0 ]; then
	echo "This script must be run as root ..."
	exit
fi

# PATH and co
. /etc/profile

# Xdialog and friends
export DISPLAY=:0

(
	rc mysql stop
	flexbackup -set all 2>&1
	rc mysql start
) | Xdialog --no-cancel --log - 20 60

