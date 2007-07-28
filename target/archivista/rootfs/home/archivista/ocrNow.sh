#!/bin/bash

if [ "$UID" -ne 0 ]; then
	exec gnomesu -p -t "Start ocr batch job right now" \
	-m "Please enter the system password (root user)^\
in order to start the ocr batch job right now." -c $0
fi

# PATH and co
. /etc/profile

# include shared code
. ${0%/*}/connect.in

host=`get_host`
db=`get_db`
user=`get_user`
pw=`get_pw`
range=`get_range "Range of documents for ocr job (e.g. 2-4 or just 5):"`
Xdialog --yesno "Really restart ocr batch job with range $range " 8 50 || exit
/home/cvs/archivista/jobs/ocrNow.pl $db $range $host $user $pw  

