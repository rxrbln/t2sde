#!/bin/bash

if [ "$UID" -ne 0 ]; then
	exec gnomesu -t "Enable ftp" \
	-m "Please enter the system password (root user)^\
in order to setup the ftp server." -c $0
fi

# PATH and co
. /etc/profile

# get the new password:
tmp1=`mktemp`
tmp2=`mktemp`

Xdialog --nocancel --passwordbox "Enter the new ftp password" 8 40 \
        2> $tmp1
Xdialog --nocancel --passwordbox "Re-enter the new ftp password" 8 40 \
        2> $tmp2

if [ -s $tmp1 ] && cmp -s $tmp1 $tmp2 ; then
        newpasswd=`cat $tmp1` ; rm $tmp1 $tmp2

	# password
	echo "ftp:$newpasswd" | chpasswd

	# enable ftp
	sed -i 's,.*\(ftp[[:blank:]].*\)$,\1,' /etc/inetd.conf 

	rc inetd restart
else
	Xdialog --msgbox 'Supplied passwords did not match!' 8 40
fi

