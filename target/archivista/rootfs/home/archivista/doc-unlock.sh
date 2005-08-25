#!/bin/bash

if [ "$UID" -ne 0 ]; then
        exec gnomesu -t "Document unlocking" \
        -m "Please enter the system password (root user)^\
in order to unlock documents." -c $0
fi

# PATH and co
. /etc/profile

until [ "$range" ]; do
        trange=`Xdialog --stdout --inputbox "Document range to unlock:
(e.g. 1-3 or 4)" \
	        10 40 "$trange"` || exit
	# remove spaces ...
	trange="${trange// /}"
	# remove invalid content
	if echo "$trange" | grep -q "^\([0-9]\+-[0-9]\+\|[0-9]\+\)$" ; then
                range="$trange"
        else
                Xdialog --infobox "Range not valid!" 8 28
        fi
done

echo $range
