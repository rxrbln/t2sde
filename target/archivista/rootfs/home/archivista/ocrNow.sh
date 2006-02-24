#!/bin/bash

if [ "$UID" -ne 0 ]; then
	exec gnomesu -p -t "Start ocr batch job right now" \
	-m "Please enter the system password (root user)^\
in order to start the ocr batch job right now." -c $0
fi

# PATH and co
# . /etc/profile

/home/cvs/archivista/jobs/ocrNow.pl $PASSWD
