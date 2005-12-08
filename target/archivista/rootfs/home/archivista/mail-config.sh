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

set -x

[ -e /etc/mail.conf ] && . /etc/mail.conf

[ "$To" -a $noreconfig = 1 ] && exit

To=`Xdialog --stdout --inputbox "Mail address to send notifications to:" \
    0 0 $To`

echo "To=\"$To\"" > /etc/mail.conf
