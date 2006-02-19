#!/bin/bash

# Copyright (C) 2005 Archivista GmbH
# Copyright (C) 2005 Rene Rebe

if [ "$UID" -ne 0 ]; then
	exec gnomesu -t "Configure scan button " \
	     -m "Please enter the system password (root user)^\
in order to configure the scan button." -c $0
fi

# PATH and co
. /etc/profile

# include shared code
. ${0%/*}/perl-var.in

[ -f /etc/av-button.conf ] && . /etc/av-button.conf
def=; [ "$av_button" != 1 ] && def="--default-no"
Xdialog $def --yesno "Enable the scan button?" 0 0 &&
av_button=1 || av_button=0

if [ "$av_button" != 1 ]; then
	cat > /etc/av-button.conf <<-EOT
		av_button=$av_button
EOT
	# immediatly kill potentially running daemons
	killall av-xevie-sb
	exit
fi

host=`get_perl_var '\$val{host1}' /home/cvs/archivista/jobs/sane-button.pl`
db=`get_perl_var '\$val{db1}' /home/cvs/archivista/jobs/sane-button.pl`
user=`get_perl_var '\$val{user1}' /home/cvs/archivista/jobs/sane-button.pl`
pw=`get_perl_var '\$val{pw1}' /home/cvs/archivista/jobs/sane-button.pl`

host=`Xdialog --stdout --inputbox "Host:" 0 0 $host` || exit
db=`Xdialog --stdout --inputbox "Database:" 0 0 $db` || exit
user=`Xdialog --stdout --inputbox "Default user:" 0 0 $user` || exit
pw=`Xdialog --stdout --passwordbox "Password:" 0 0 $pw` || exit

set_perl_var '\$val{host1}' /home/cvs/archivista/jobs/sane-button.pl "$host"
set_perl_var '\$val{db1}' /home/cvs/archivista/jobs/sane-button.pl "$db"
set_perl_var '\$val{user1}' /home/cvs/archivista/jobs/sane-button.pl "$user"
set_perl_var '\$val{pw1}' /home/cvs/archivista/jobs/sane-button.pl "$pw"

# only enable it when no cancel was hit above
cat > /etc/av-button.conf <<-EOT
av_button=$av_button
EOT

# start immediatly, if not yet running
ps -C av-xevie-sb >/dev/null || nohup /usr/bin/av-xevie-sb \
--script /home/cvs/archivista/jobs/sane-button.pl >/tmp/av-xevie-sb.log &

