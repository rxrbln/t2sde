#!/bin/sh

XDM="/usr/X11/bin/xdm -nodaemon"

[ -e /etc/conf/xdm ] && . /etc/conf/xdm

exec $XDM

