#!/bin/bash

CONFIG=$1

echo "Appending LVS Configuration to $CONFIG ... "
[ -z "$CONFIG" ] && exit 1

echo -e "\n# LVS" >> $CONFIG

for x in NETFILTER IP_VS
do
	echo "CONFIG_$x=y" >> $CONFIG
done
