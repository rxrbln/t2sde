#!/bin/sh

XDM=/usr/X11/bin/xdm

[ -e /etc/conf/xdm ] && . /etc/conf/xdm

$XDM

