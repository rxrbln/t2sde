#!/bin/bash

if [ "$UID" -ne 0 ]; then
	exec gnomesu -t "Enable PDF printing" \
	-m "Please enter the system password (root user)^\
in order to setup PDF printing (CUPS)." -c $0
fi

# PATH and co
. /etc/profile

tip=`ifconfig eth0 | sed -n "s/.*inet addr:\([^ ]\+\) .*/\1/p"`
if [ "$tip" ]; then
	tip=${tip%.[0-9]*}.0/24
else
	tip="192.168.0.0/24"
fi

until [ "$ip" ]; do
	tip=`Xdialog --stdout --no-cancel \
	     --inputbox "Internet address and network
prefix in CIDR notation of
computers allowed to print
(e.g. 192.168.0.0/24 or 10.0.0.0/16):" 10 38 $tip`

	# check ip
	if [ `echo $tip |
		sed 's,[0-9]\+.[0-9]\+.[0-9]\+.[0-9]\+/[0-9]\+,,'` ]
	then
		Xdialog --infobox "IP not valid!" 8 28
	else
		ip=$tip
	fi
done

# rewrite config file - inject allowed IP range
gawk "BEGIN { matched=0 }

/<Location \/>/ {
	print
	matched=1
	print \"Order Deny,Allow\nDeny From All\nAllow From 127.0.0.1\nAllow From $ip\"
}

/<\/Location>/ {
	matched=0
}

{
	if ( matched == 0 )
		print
}" < /etc/cups/cupsd.conf > /etc/cups/cupsd.conf.new
cat /etc/cups/cupsd.conf.new > /etc/cups/cupsd.conf
rm /etc/cups/cupsd.conf.new
# ^- a bit tricky to preserve access rights

# start CUPS now

rc cups start

# add printer to CUPS (CUPS needs to be running for this)
lpadmin -p archivista -L "Archivista Box" -D "PDF print into database." \
        -E -v "cups-pdf:/" -m PostscriptColor.ppd.gz

# enable CUPS at startup
ln -sf ../init.d/cups /etc/rc.d/rc5.d/S30cups
ln -sf ../init.d/cups /etc/rc.d/rc5.d/K70cups

Xdialog --title "" --msgbox "PFD printing (CUPS) enabled." 0 0

