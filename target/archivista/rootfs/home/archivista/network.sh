#!/bin/bash

# Simple custom network configuration.
#
# Copyright (C) 2005 Archivista GmbH
# Copyright (C) 2005 Rene Rebe

PATH=/sbin:/usr/sbin:$PATH

reconfig=0

if [ "$1" = -reconfig ]; then
	reconfig=1
	shift
fi


get_ip()
{
	x=$2
        until [ "$set" ]; do
                x=`Xdialog --stdout --inputbox "$1" 10 38 $x`

                # check ip
                if [ `echo $x |
                      sed 's,[0-9]\+.[0-9]\+.[0-9]\+.[0-9]\+,,'` ]
                then
                        Xdialog --infobox "IP not valid!" 8 28
                else
                        set=1
                fi
        done
	echo $x
}

# initial config or reconfig requested?
if [ -e /etc/conf/network -a $reconfig = 0 ]; then
	echo "Config exists, no reconfig -> exiting."
	exit
fi

# if exists get default values ...
if [ -e /etc/conf/network ]; then
        tip=`sed '/ip /s,.*ip ,,p;d' /etc/conf/network`
	ifdown eth0
elif ! Xdialog --yesno "The network connection is not yet
configured. Configure now?" 8 34; then
	echo not yet
	touch /etc/conf/network
	exit
fi

if Xdialog --yesno "Use DHCP to obtain\nconfiguration?" 8 28; then
	cat > /etc/conf/network <<-EOT
interface eth0
	dhcp
EOT
else
	tip=${tip:-192.168.0.100/24}
	until [ "$ip" ]; do
		tip=`Xdialog --stdout --inputbox "Internet address and network
prefix in CIDR notation
(e.g. 192.168.0.100/24 or 10.0.0.100/16):" 10 38 $tip`

		# check ip
		if [ `echo $tip |
		      sed 's,[0-9]\+.[0-9]\+.[0-9]\+.[0-9]\+/[0-9]\+,,'` ]
		then
			Xdialog --infobox "IP not valid!" 8 28
		else
			ip=$tip
		fi
	done

	gw=`get_ip "Gateway address
(e.g. 192.168.0.1):" ${ip%.*}.1`
	[ "$gw" ] && ns=`get_ip "Nameserver address
(e.g. 192.168.0.1):" ${gw}`

	cat > /etc/conf/network <<EOT
interface eth0
        ip $ip
EOT
	[ "$gw" ] && cat >> /etc/conf/network <<EOT
	gw $gw
EOT
	[ "$ns" ] && cat >> /etc/conf/network <<EOT
        nameserver $ns
EOT

fi

ifup eth0
