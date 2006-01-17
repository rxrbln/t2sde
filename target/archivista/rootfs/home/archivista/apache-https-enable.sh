#!/bin/bash

if [ "$UID" -ne 0 ]; then
	exec gnomesu -t "Enable HTTPS (SSL)" \
	-m "Please enter the system password (root user)^\
in order to setup HTTPS (SSL) for the web server." -c $0
fi

# PATH and co
. /etc/profile

# sanity check for user response
if grep -q DSSL /sbin/init.d/apache; then
        Xdialog --default-no --yesno "Support for https is already enabled.
Create new a new X.509 certificate?" 0 0 || exit
fi

cd /etc/opt/apache
mkdir -p ssl.{crt,key}

# previous options for usability
[ -e ./last ] && . ./last

[ "$ip" ] || ip=`ifconfig eth0 | sed -n "s/.*inet addr:\([^ ]\+\) .*/\1/p"`
ip=`Xdialog --stdout --inputbox "Server IP or hostname:" 0 0 $ip` || exit

tcountry="$country"; country=""
until [ "$country" ]; do
	tcountry="`Xdialog --stdout --inputbox "Country (code):" \
	          0 0 $tcountry`" || exit
	# upper case
	tcountry="`echo $tcountry | tr a-z A-Z`"
	# valid two letter code?
	if [[ "$tcountry" = [A-Z][A-Z] ]]; then
		country="$tcountry"
	else
		Xdialog --msgbox "The country must be a two letter
ISO 3166 code, for example US, DE or CH." 0 0
	fi
done

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

# save config for the defaults of the next run
cat > last <<-EOT
country=$country
state=$state
city=$city
org=$org
dep=$dep
mail=$mail
EOT

# size greater than zero?
if [ ! -s ssl.key/server.key -o ! -s ssl.crt/server.crt ]; then
	Xdialog --msgbox "An error occured creating the private key
or X.509 certificate for https." 0 0
	exit
fi

# tweak init script to start with SSL suport
sed -i "s/apachectl .*start/apachectl -DSSL -k start/" /sbin/init.d/apache

# tweak the window manager references to http - menu, keys, startup
sed -i 's,http://localhost/,https://localhost/,g' /home/archivista/.fluxbox/*
killall -USR2 fluxbox

rc apache stop
rc apache start

Xdialog --title "" --msgbox "HTTPS (SSL) enabled." 0 0

