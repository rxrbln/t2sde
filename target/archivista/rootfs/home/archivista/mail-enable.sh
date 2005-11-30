#!/bin/bash

if [ "$UID" -ne 0 ]; then
	exec gnomesu -t "Enable mail" \
	-m "Please enter the system password (root user)^\
in order to enable the mail server." -c $0
fi

# PATH and co
. /etc/profile

# start EXIM now
rc exim start

# enable EXIM at startup
ln -sf ../init.d/exim /etc/rc.d/rc5.d/S25exim
ln -sf ../init.d/exim /etc/rc.d/rc5.d/K75exim

