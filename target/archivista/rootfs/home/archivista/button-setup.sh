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

set -x
host=`get_perl_var '\$val{host1}' /home/cvs/archivista/jobs/sane-button.pl`
db=`get_perl_var '\$val{db1}' /home/cvs/archivista/jobs/sane-button.pl`
user=`get_perl_var '\$val{user1}' /home/cvs/archivista/jobs/sane-button.pl`
pw=`get_perl_var '\$val{pw1}' /home/cvs/archivista/jobs/sane-button.pl`

host=`Xdialog --stdout --inputbox "Host:" 0 0 $host`
db=`Xdialog --stdout --inputbox "Database:" 0 0 $db`
user=`Xdialog --stdout --inputbox "Default user:" 0 0 $user`
pw=`Xdialog --stdout --passwordbox "Password:" 0 0 $pw`

set_perl_var '\$val{host1}' /home/cvs/archivista/jobs/sane-button.pl "$host"
set_perl_var '\$val{db1}' /home/cvs/archivista/jobs/sane-button.pl "$db"
set_perl_var '\$val{user1}' /home/cvs/archivista/jobs/sane-button.pl "$user"
set_perl_var '\$val{pw1}' /home/cvs/archivista/jobs/sane-button.pl "$pw"

