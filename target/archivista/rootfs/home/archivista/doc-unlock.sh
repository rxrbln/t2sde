#!/bin/bash

until [ "$range" ]; do
        trange=`Xdialog --stdout --inputbox "Document range to unlock:" \
	        10 40 "$tdays"`
        if [[ "$trange" = [0-9]*-[0-9]* ]]; then
                range="$trange"
        else
                Xdialog --infobox "Ragne not valid!" 8 28
        fi
done

echo $range
