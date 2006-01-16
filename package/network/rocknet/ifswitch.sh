#!/bin/bash

set -e

active=$( cat /var/run/rocknet/active-interfaces 2>/dev/null || true )

if [ $# -eq 0 ]; then
	echo "Usage $0 [ interface profile ] | [ profile ]"
	exit
fi

i=0
for x in ${active//,/ }; do
	[ $(( i++ )) -eq 0 ] && echo "Deactivating current interfaces ..."
	if=${x/(*)/}
	profile=${x/*(/}; profile=${profile%)}
	ifdown $if $profile
done

echo "Activating specified profile/interfaces ..."

if [ $# -eq 1 ]; then
	rocknet $1 auto up
else
	ifup $1 $2
fi
