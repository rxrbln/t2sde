#!/bin/bash

if [ "$UID" -ne 0 ]; then
        exec gnomesu -t "Reset password for user account" \
        -m "Please enter the system password (root user)^\
in order to reset a password for an user account." -c $0 -p
fi

# PATH and co
. /etc/profile

until [ "$user" ]; do
  mess="User to reset the password \n(i.e. user@localhost):" 
  user=`Xdialog --stdout --inputbox "$mess" 10 40 "$user"` || exit
	user="${user// /}"
done

/home/cvs/archivista/jobs/passwordreset.pl $user 
error=$?

if [ $error -eq 0 ]; then
  Xdialog --msgbox "Password for $user is resetted" 8 40
else
	Xdialog --msgbox "Password for $user NOT resetted" 8 40
fi
