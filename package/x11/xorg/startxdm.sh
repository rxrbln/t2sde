#!/bin/sh

XDM=/usr/X11/bin/xdm

[ -e /etc/conf/xdm ] && . /etc/conf/xdm

[ "$1" = "-nodeamon" ] && case $XDM in
	gdm*|kdm*|xdm*) ;;
	*) shift ;;
esac

$XDM "$@"

