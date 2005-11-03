#!/bin/bash

doit=1

[ "$1" == "-dry" ] && doit=0 && shift

from="$1" ; shift
to="$1" ; shift

if [ -z "$from" ] || [ -z "$to" -a $doit -ne 0 ]; then
	echo "Usage: $0 [ -dry ] from-dir to-dir"
	exit
fi

# include specified configuration values
if [ ! -e $from/config ]; then
	echo "$from/config does not exist"
	exit
fi
. $from/config

[ $doit = 1 ] && cd $to

# passwords
if [ "$update_root_hash" ]; then
	echo "root password hash"
	[ $doit = 1 ] &&
	  sed -i "s,root:[^:]*,root:$update_root_hash," etc/shadow 
fi

if [ "$update_archivista_hash" ]; then
	echo "archivista password hash"
	[ $doit = 1 ] &&
	  sed -i "s,archivista:[^:]*,archivista:$update_archivista_hash," \
	         etc/shadow
fi

if [ "$update_ftp_hash" ]; then
	echo "ftp password hash"
	[ $doit = 1 ] &&
	  sed -i "s,ftp:[^:]*,ftp:$update_ftp_hash," etc/shadow
fi

# perl class
if [ "$update_root_perl_passwd" ]; then
	echo "archivista class password"
	if [ $doit = 1 ]; then
	  sed -i "s/\(.*MYSQL_PWD.* = \).*/\1\"$update_root_perl_passwd\";/" \
	         home/cvs/archivista/apcl/Archivista/Config.pm

	  sed -i "/sub avdb_pwd/ { N ; s/\".*\"/\"$update_root_perl_passwd\"/ }" \
	         home/cvs/archivista/webclient/perl/inc/Global.pm
	fi
fi

# gnupg key
if [ -e $from/.gnupg ]; then
	echo "encryption keys"
	if [ $doit = 1 ]; then
	  cp -rfv $from/.gnupg home/archivista/
	  chmod 700 home/archivista/.gnupg
	  chmod 600 home/archivista/.gnupg/*
	fi
fi

# ssh key
if [ -e $from/ssh_host_key ]; then
	echo "SSH keys"
	if [ $doit = 1 ]; then
	  cp -fv $from/ssh_*key* etc/ssh/
	  chmod 600 etc/ssh/ssh_*_key
	fi
fi

# network
if [ -e $from/network ]; then
	echo "network configuration"
	[ $doit = 1 ] && cp -fv $from/network etc/conf/network
fi

# https
if [ "$update_apache_https" ]; then
	echo "https enabled"
	if [ $doit = 1 ]; then
	  # tweak init script to start with SSL suport
	  sed -i "s/apachectl .*start/apachectl -DSSL -k start/" sbin/init.d/apache

	  # tweak the window manager references to http - menu, keys, startup
	  sed -i 's,http://localhost/,https://localhost/,g' home/archivista/.fluxbox/*

	  cp -rv $from/ssl.{crt,key} etc/opt/apache/
	  chmod 600 etc/opt/apache/ssl.key/*.key
	fi
fi

# cups
# TODO

# backup
if [ "$update_backup" ]; then
	echo "backup time and date"
	if [ $doit = 1 ]; then
	  sed -i "/\/backup.sh/d" -i etc/crontab
	  echo "$update_backup root /home/archivista/backup.sh" \
	  >> etc/crontab
	fi
fi

# network backup
if [ "$update_net_backup" ]; then
	echo "net-backup time and date"
	if [ $doit = 1 ]; then
	  sed -i "/\/net-backup.sh/d" -i etc/crontab
	  echo "$update_net_backup root /home/archivista/net-backup.sh" \
	  >> etc/crontab
	  cp -fv $from/net-backup.conf etc/
	fi
fi

# ftp
if [ "$update_ftp_enabled" ]; then
	echo "ftp enabled"
	[ $doit = 1 ] &&
          sed -i 's,.*\(ftp[[:blank:]].*\)$,\1,' etc/inetd.conf
fi

# OCR reg key
if [ -e $from/av5.con ]; then
	echo "OCR registration"
	if [ $doit = 1 ];
	  cp -fv $from/av5.con home/archivista/.wine/drive_c/Programs/Av5e/
	  chmod archivista:users home/archivista/.wine/drive_c/Programs/Av5e/av5.con
	fi
fi
