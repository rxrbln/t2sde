#!/bin/bash

if [ "$UID" -ne 0 ]; then
        exec gnomesu -t "RichClient scan access" \
        -m "Please enter the system password (root user)^\
in order to grant/revoke access to/from an external RichClient user." -c $0 -p
fi

# PATH and co
. /etc/profile

until [ "$user" ]; do
  mess="Enter user to grant/revoke access to/from\n(i.e. user@192.168.0.1):" 
  user=`Xdialog --stdout --inputbox "$mess" 10 40 "$user"` || exit
	user="${user// /}"
done

pw1="a1"
pw2="a2"
until [ "$pw1" = "$pw2" ]; do
  m1="Enter password for $user:" 
	m2="Repeat password for $user:"
  pw1=`Xdialog --stdout --password --inputbox "$m1" 10 40 ""` || exit
  pw2=`Xdialog --stdout --password --inputbox "$m2" 10 40 ""` || exit
	pw1="${pw1// /}"
	pw2="${pw2// /}"
	m3="Passwords do not match. Please enter the passwords again."
	if [ "$pw1" != "$pw2" ]; then
	  Xdialog --stdout --msgbox "$m3" 10 40
	fi 
done

# first check, if the user already has rights
/home/cvs/archivista/jobs/richclientuser.pl status $user $pw1
mode=$?

if [ $mode -eq 0 ]
then
  msg="$user is not a known user or does not exist"
  Xdialog --msgbox "$msg" 8 60
	exit
elif [ $mode -eq 1 ]
then
  Xdialog --yesno "Grant access to $user" 0 0 || exit
  /home/cvs/archivista/jobs/richclientuser.pl grant $user $pw1
	success=$?
	msg="Access to $user was granted"
elif [ $mode -eq 2 ]
then
  Xdialog --yesno "Revoke access from $user" 0 0 || exit
  /home/cvs/archivista/jobs/richclientuser.pl revoke $user $pw1
	success=$?
	msg="Access was revoked from $user"
elif [ $mode -eq 3 ]
then
  msg="User $user created!"
	success=3
fi

if [ $success -eq 0 ]
then
  msg="An error occurred"
fi

Xdialog --msgbox "$msg" 8 40
