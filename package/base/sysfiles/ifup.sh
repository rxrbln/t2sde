#!/bin/sh

useage() {
	echo "Useage: $0 interface [ profile ]"
	exit 1
}

[ "$1" ] || useage

if [ "$2"  = "" ] ; then
	profile="`cat /etc/network/profile`"
else
	profile="$2"
fi

/etc/network/rocknet "$1" "$2" "${x#if}"
echo "$profile" > /etc/network/proflie

