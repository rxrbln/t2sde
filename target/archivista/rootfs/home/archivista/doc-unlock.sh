#!/bin/bash

if [ "$UID" -ne 0 ]; then
        exec gnomesu -t "Document unlocking" \
        -m "Please enter the system password (root user)^\
in order to unlock documents." -c $0 -p
fi

# PATH and co
. /etc/profile

# include shared code
. ${0%/*}/connect.in

host=`get_host`
db=`get_db`
user=`get_user`
pw=`get_pw`
range=`get_range "Range of documents to unlock (e.g. 2-4 or just 5):"`
unlock="$host $db $user $pw unlock $range"
/home/cvs/archivista/jobs/avdbutility.pl $unlock 
error=$?

if [ $error -eq 0 ]; then
  Xdialog --msgbox "Documents $trange in database $db unlocked" 8 40
else
  Xdialog --msgbox "Error: Documents $trange in database $db could not be unlocked!" 8 40
fi
