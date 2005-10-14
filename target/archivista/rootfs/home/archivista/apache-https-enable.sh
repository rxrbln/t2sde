#!/bin/bash

if [ "$UID" -ne 0 ]; then
	exec gnomesu -t "Enable https (SSL)" \
	-m "Please enter the system password (root user)^\
in order to setup https (SSL) for the web server." -c $0
fi

# PATH and co
. /etc/profile

cd /etc/opt/apache
mkdir -p ssl.{crt,key}

# previous options for usability
[ -e ./last ] && . ./last

[ "$ip" ] || ip=`ifconfig eth0 | sed -n "s/.*inet addr:\([^ ]\+\) .*/\1/p"`
ip=`Xdialog --stdout --inputbox "Server IP or hostname:" 0 0 $ip` || exit
country=`Xdialog --stdout --inputbox "Country (code):" 0 0 $country` || exit
state=`Xdialog --stdout --inputbox "State or Province:" 0 0 $state` || exit
city=`Xdialog --stdout --inputbox "City:" 0 0 $city` || exit
org=`Xdialog --stdout --inputbox "Organization:" 0 0 $org` || exit
dep=`Xdialog --stdout --inputbox "Department:" 0 0 $dep` || exit

openssl genrsa -out ssl.key/server.key 1024
chmod 400 ssl.key/server.key
openssl req -new -key ssl.key/server.key -x509 -days 365 -out ssl.crt/server.crt <<-EOT
$country
$state
$city
$org
$dep
$ip
$mail
EOT

# save config for the net-backup.sh script
cat > last <<-EOT
country=$country
state=$state
city=$city
org=$org
dep=$dep
mail=$mail
EOT

# tweak init script to start with SSL suport
sed -i "s/apachectl .*start/apachectl -DSSL -k start/" /sbin/init.d/apache

# tweak the window manager references to http - menu, keys, startup
sed -i s/http:/https:/g /home/archivista/.fluxbox/*

rc apache stop
rc apache start

