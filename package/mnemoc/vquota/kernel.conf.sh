#!/bin/bash

CONFIG=$1

echo "Appending VQuota Configuration to $CONFIG ... "
[ -z "$CONFIG" ] && exit 1

echo -e "\n# VQuota" >> $CONFIG

for x in QUOTA BLK_DEV_VROOT
do
	echo "CONFIG_$x=y" >> $CONFIG
done
