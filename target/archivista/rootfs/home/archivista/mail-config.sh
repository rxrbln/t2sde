#!/bin/bash

if [ "$UID" -ne 0 ]; then
	exec gnomesu -t "Configure mail" \
	-m "Please enter the system password (root user)^\
in order to configure the notification mail address." -c "$*"
fi

noreconfig=0
[ "$1" = -noreconfig ] && noreconfig=1

# PATH and co
. /etc/profile

[ -e /etc/mail.conf ] && . /etc/mail.conf
[ "$To" -a $noreconfig = 1 ] && exit

To=`Xdialog --stdout --inputbox "Mail address(es) to send event \
notifications to:" 0 0 $To` || exit

echo "To=\"$To\"" > /etc/mail.conf
