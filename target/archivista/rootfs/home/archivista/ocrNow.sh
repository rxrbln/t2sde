#!/bin/bash

if [ "$UID" -ne 0 ]; then
	exec gnomesu -p -t "Start ocr batch job right now" \
	-m "Please enter the system password (root user)^\
in order to start the ocr batch job right now." -c $0
fi

# PATH and co
. /etc/profile

msg="To restart ocr batch job"

get_range ()
{
  local x
  until [ "$x" ]; do
	tx=`Xdialog --stdout --cancel-label=All --inputbox "$1" 10 50 "$tx"` \
	   || return
	# remove spaces ...
	tx="${tx// /}"
	# remove invalid content
	if echo "$tx" | grep -q "^\([0-9]\+-[0-9]\+\|[0-9]\+\)$" ; then
		x=$tx
	else
		Xdialog --infobox "Range not valid!" 8 28
	fi
  done
  echo $x
}



get_db()
{
  db="archivista"
  while
	db=`Xdialog --stdout --no-cancel --inputbox "Database to use:" \
	    10 40 "$db"`
	[ -z "$db" ]
  do
	:
  done
  echo $db
}



db=`get_db`

range=`get_range "Range of documents for ocr job (e.g. 2-4 or just 5):"`

Xdialog --yesno "Really restart ocr batch job with range $range " 8 50 || exit

/home/cvs/archivista/jobs/ocrNow.pl $db $range 

