#!/bin/sh

usage() {
	echo "Usage: $0 interface [ profile ]"
	exit 1
}

[ "$1" ] || usage

if [ "$2" = "" ] ; then
	profile="`cat /etc/network/profile 2> /dev/null`"
else
	profile="$2"
fi

profile=${profile:-default}

/etc/network/rocknet "$profile" "$1" "${0#/sbin/if}"
echo "$profile" > /etc/network/profile

