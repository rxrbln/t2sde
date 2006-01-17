#!/bin/bash

if [ "$UID" -ne 0 ]; then
	exec gnomesu -t "Setup backup to rsync location" \
	-m "Please enter the system password (root user)^\
in order to setup the rsync backup." -c $0
fi

# PATH and co
. /etc/profile

# include shared code
. ${0%/*}/backup-setup.in /home/archivista/net-backup.sh

get_days

# disable?
if [ "$tdays" = 0 ]; then
	crontab_remove /home/archivista/rsync-backup.sh
	exit
fi

get_time

# maybe previous values ...
[ -e /etc/rsync-backup.conf ] && . /etc/rsync-backup.conf

# server / user / pass / ...

server=`Xdialog --stdout --inputbox "Server IP (or hostname):" 0 0 $server` || exit
user=`Xdialog --stdout --inputbox "User account:" 0 0 $user` || exit
dir=`Xdialog --stdout --inputbox "Directory:" 0 0 $dir` || exit

# save config for the net-backup.sh script
(
  echo "server=$server"
	echo "user=$user"
  echo "dir=$dir"
) > /etc/rsync-backup.conf
chmod 400 /etc/rsync-backup.conf # hide passwords from users

genkey=1
if [ -f ~/.ssh/id_rsa ]; then
	Xdialog --default-no --yesno "Regenerate existing private /
public key-pair?" 0 0 || genkey=0
fi

if [ $genkey -eq 1 ]; then
	rm -f ~/.ssh/id_rsa
	ssh-keygen -q -f ~/.ssh/id_rsa -t dsa -N ''
fi

# copy key
set -x
tmp=`mktemp`
xterm -rv -fa Mono -e \
"ssh $user@$server 'mkdir -p ~/.ssh ; cat >> ~/.ssh/authorized_keys' < \
~/.ssh/id_rsa.pub && echo 1 > $tmp"

if [ "`cat $tmp`" = 1 ]; then
	crontab_add /home/archivista/rsync-backup.sh $h $m $days
	Xdialog --msgbox "Public key copied and rsync backup enabled." 0 0
else
	Xdialog --msgbox "There was an error transfering the public key,
rsync backup not enabled." 0 0
fi

