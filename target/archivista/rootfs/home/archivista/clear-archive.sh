#!/bin/bash

# PATH and co
. /etc/profile

dbdir=/home/data/archivista/mysql

# Xdialog and friends
export DISPLAY=:0

if [ "$UID" -ne 0 ]; then
        exec gnomesu -t "Clear Archiv" \
        -m "Please enter the system password (root user)^\
in order to delete Documents/Folders in the Database." -c $0
fi

until [ "$db" ]; do
  mess="Choose the database to delete documents/folders"
  db=`Xdialog --stdout --inputbox "$mess" 10 48 "$db"` || exit
	db="${db// /}"
done

mode=`Xdialog --title 'Clear Archiv' --stdout --no-tags --separator ' ' --radiolist \
"Choose type which you want to delete" 0 0 3 \
1 'Documents' off \
2 'Folders'   off` || exit


until [ "$range" ]; do
  trange=`Xdialog --stdout --inputbox "Range that we want to delete" 10 48 "$tdays"` || exit
  # remove spaces ...
  trange="${trange// /}"
  # remove invalid content
	echo "$trange"
	if echo "$trange" | grep -q "^\([0-9]\+-[0-9]\+\|[0-9]\+\)$" ; then
    range=$trange
  else
    Xdialog --infobox "Range not valid!" 8 28
  fi
done

if [ $mode -eq 1 ];then
  rows=`/home/cvs/archivista/jobs/clear-archive.pl Documents $db $range`
elif  [ $mode -eq 2 ];then
  rows=`/home/cvs/archivista/jobs/clear-archive.pl Folders $db $range`
fi

Xdialog --msgbox "$rows Documents deleted" 0 0
