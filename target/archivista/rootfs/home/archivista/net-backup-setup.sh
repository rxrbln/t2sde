#!/bin/bash

if [ "$UID" -ne 0 ]; then
	exec gnomesu -t "Setup backup to network location" \
	-m "Please enter the system password (root user)^\
in order to setup the network backup." -c $0
fi

# PATH and co
. /etc/profile

# include shared code
. ${0%/*}/backup-setup.in /home/archivista/net-backup.sh

get_days

# disable?
if [ "$tdays" = 0 ]; then
	crontab_remove /home/archivista/net-backup.sh
	exit
fi

get_time

# maybe previous values ...
[ -e /etc/net-backup.conf ] && . /etc/net-backup.conf

# type: cifs / nfs / ...

type=`Xdialog --stdout --combobox "Protocol used to access the remote server.
CIFS stands for Common Internet Filesystem (formerly
known as SMB) is used on Microsoft servers, where
NFS is usually used in Unix environments." 0 0 CIFS NFS | tr A-Z a-z` || exit

# server / user / pass / ...

server=`Xdialog --stdout --inputbox "Server IP (or hostname):" 0 0 $server` || exit
share=`Xdialog --stdout --inputbox "Share:" 0 0 $share` || exit

if [ $type = cfs ]; then
	user=`Xdialog --stdout --inputbox "User account:" 0 0 $user` || exit
	passwd=`Xdialog --stdout --passwordbox "Password:" 0 0 $passwd` || exit
	domain=`Xdialog --stdout --cancel-label=None --inputbox "Domain:" 0 0 $domain`
# else # NFS specific stuff
fi

# save config for the net-backup.sh script
(
  echo "type=$type"
  echo "server=$server"
  echo "share=$share"

  if [ $type = cifs ]; then
	[ "$user" ] && echo "user=$user"
	[ "$passwd" ] && echo "passwd=$passwd"
	[ "$domain" ] && echo "domain=$domain"
  fi
) > /etc/net-backup.conf
chmod 400 /etc/net-backup.conf # hide passwords from users

crontab_add /home/archivista/net-backup.sh $h $m $days

