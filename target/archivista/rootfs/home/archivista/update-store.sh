#!/bin/bash

from="$1" ; shift
to="$1" ; shift

if [ -z "$from" -o -z "$to" ]; then
	echo "Usage: $0 from-dir to-dir"
	exit
fi

cd $from

# passwords
update_root_hash=`grep '^root:' etc/shadow | cut -d : -f 2`
update_archivista_hash=`grep '^archivista:' etc/shadow | cut -d : -f 2`
update_ftp_hash=`grep '^ftp:' etc/shadow | cut -d : -f 2`

# mysql does not need to be saved - it is in /home/data/

# perl class
update_root_perl_passwd=`grep 'MYSQL_PWD' \
                         usr/lib/perl5/*/Archivista/Config.pm | cut -d \" -f 2`

# gnupg key
cp -rfv home/archivista/.gnupg $to/ 2>/dev/null

# ssh key
cp -fv etc/ssh/ssh_*key* $to/ 2>/dev/null

# network
cp etc/conf/network $to/

# https
grep -q '\-DSSL' sbin/init.d/apache && update_apache_https=1
cp -rfv etc/opt/apache/ssl.{crt,key} $to/ 2>/dev/null

# cups
# TODO

# backup
update_backup=`grep archivista/backup.sh etc/crontab | cut -d ' ' -f 1-5`

# network backup
update_net_backup=`grep archivista/net-backup.sh etc/crontab |
                   cut -d ' ' -f 1-5`
cp -fv etc/net-backup.conf $to/ 2>/dev/null

grep -q '^ftp' etc/inetd.conf && update_ftp_enabled=1

# OCR reg key?

# store all update variables
for var in ${!update_*}; do
	declare -p $var
done > $to/config

