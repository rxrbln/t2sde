#!/bin/bash

if [ "$UID" -ne 0 ]; then
	exec gnomesu -t "Enable incoming mail" \
	-m "Please enter the system password (root user)^\
in order to enable incoming mail server." -c $0
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
computers allowed to send mail
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

# open for the public
sed -i -e 's/^\([^# ]*local_interfaces \)/# \1/' \
       -e " s|^\(hostlist .*relay_from_hosts = 127.0.0.1\).*|\1 : $ip|" \
       /etc/exim/configure

# restart EXIM now
rc exim restart

Xdialog --title "" --msgbox "Incoming mail server enabled." 0 0

