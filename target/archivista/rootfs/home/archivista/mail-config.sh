#!/bin/bash

if [ "$UID" -ne 0 ]; then
	exec gnomesu -t "Configure mail" \
	-m "Please enter the system password (root user)^\
in order to configure the notification mail address." -c "$0 $*"
fi

noreconfig=0
[ "$1" = -noreconfig ] && noreconfig=1

# PATH and co
. /etc/profile

[ -e /etc/mail.conf ] && . /etc/mail.conf
[ "$To" -a $noreconfig = 1 ] && exit

To=`Xdialog --stdout --inputbox "Mail address(es) to send event \
notifications to:" 0 0 "$To"` || exit

[ "$From" ] || From="Archivista Box"
From=`Xdialog --stdout --inputbox "Address used as identification (From:):" \
0 0 "$From"` || exit


echo "To=\"$To\"
From=\"$From\"" > /etc/mail.conf

