#!/bin/sh

XDM=/usr/X11/bin/xdm

[ -e /etc/conf/xdm ] && . /etc/conf/xdm

function check_dm() {
	echo $XDM | grep -q $1
}

if [ "$1" = "-nodaemon" ] &&
		! check_dm gdm && ! check_dm kdm && ! check_dm xdm
then
	shift
fi

$XDM "$@"

