#!/bin/bash

# Simple custom installer using Xdialog for interaction. After selecting the
# target device it will clone the live-cd onto the hard-disk using
# rsync and even display a progress bar thru Xdialog while doing so.
#
# Copyright (C) 2005 Archivista GmbH
# Copyright (C) 2005 Rene Rebe

[ "$1" ] && export user=$1 && shift

if [ ! "$user" ]; then
	echo "Usage: chpasswd user-name"
	exit
fi

if [ ! "$THIS_IS_THE_2ND_RUN" ]; then
	p=""; [ $user = root ] && p="-p"
	export THIS_IS_THE_2ND_RUN=1
	exec gnomesu -t "Password setup" \
	-m "Please enter the current system password (root user)^\
in order to set a new." $p -c $0
fi

. /etc/profile

tmp0=`mktemp`
if [ "$user" != root ]; then
	Xdialog --nocancel --passwordbox "Enter the current user password" 8 40\
	        2> $tmp0
	PASSWD=`cat $tmp0` ; rm $tmp0
fi

# now the old root or user password is in the PASSWD variable - either
# via the patched gnomesu and the -p switch exporting it - or for the user
# with the above Xdialog


# get the new password:
tmp1=`mktemp`
tmp2=`mktemp`

Xdialog --nocancel --passwordbox "Enter the new $user password" 8 40 \
        2> $tmp1
Xdialog --nocancel --passwordbox "Re-enter the new $user password" 8 40 \
        2> $tmp2

if [ -s $tmp1 ] && cmp -s $tmp1 $tmp2 ; then
	newpasswd=`cat $tmp1` ; rm $tmp1 $tmp2


	# TODO: change MySQL first, since only there we will see if the old
	# password was specified correct for the non-root user case ...

	# mysql ... bla ... -oldpasswd $PASSWD -newpassword $newpassword

	echo "$user:$newpasswd" | chpasswd

	# change the perl class-library password:
	if [ $user = root ]; then
		sed -i "s/\(.*MYSQL_PWD.* = \).*/\1\"$passwd\";/" \
		    /usr/lib/perl5/*/Archivista/Config.pm 
	fi
else
	Xdialog --msgbox 'Supplied passwords did not match!' 8 40
fi

