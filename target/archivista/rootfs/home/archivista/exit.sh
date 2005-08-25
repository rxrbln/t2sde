#!/bin/bash

if [ "$UID" -ne 0 ]; then
        exec gnomesu -t "Exit" \
        -m "Please enter the system password (root user)^\
in order to exit." -c $0
fi

killall fluxbox

