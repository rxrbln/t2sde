#!/bin/bash

if [ $UID -ne 0 ]; then
	exec gnomesu -t "System password setup" \
	-m "Please enter the current system password in order to set a new." \
	-c $0
fi

. /etc/profile

tmp1=`mktemp`
tmp2=`mktemp`

Xdialog --nocancel --passwordbox "Enter the new system-wide password" 8 40 \
        2> $tmp1

Xdialog --nocancel --passwordbox "Re-enter the new system-wide password" 8 40 \
        2> $tmp2

if [ -s $tmp1 ] && cmp -s $tmp1 $tmp2 ; then
	passwd=`cat $tmp1` ; rm $tmp1 $tmp2
	echo "root:$passwd" | chpasswd

	sed -i "s/\(.*MYSQL_PWD.* = \).*/\1\"$passwd\";/" \
	    /usr/lib/perl5/*/Archivista/Config.pm 
else
	Xdialog --msgbox 'Supplied passwords did not match!' 8 40
fi

