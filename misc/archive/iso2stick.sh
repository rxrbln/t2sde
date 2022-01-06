#!/bin/bash

set -e

if [ -z "$1" -o -z "$2" ]; then
	echo "Usage iso2stick iso-image stick-device"
	exit
fi

# # ceate fresh image
# size=`du --block-size=1000000 $1 | cut -f 1`
# size=$(( size + 20 )) # just to be sure
# 
# dd if=/dev/zero of=hd.img bs=1000000 count=$size

# loop=`losetup -f`
# losetup $loop hd.img

sfdisk ${2} << EOT
,,b
EOT

# losetup -d $loop

mkfs.vfat -F 32 ${2}1

# losetup /dev/loop0 -o 512 hd.img

mkdir -p /mnt/source /mnt/target
mount -o loop $1 /mnt/source
mount ${2}1 /mnt/target

rsync -arvH --inplace /mnt/source/ /mnt/target/

sed -i 's/(cd)/(hd0,0)/g' /mnt/target/boot/grub/menu.lst

umount /mnt/source
umount /mnt/target

echo -e "(hd0)	/dev/sda" > device.map
echo -e "root (hd0,0)\ninstall /boot/grub/stage1 (hd0) (hd0,0)/boot/grub/stage2 (hd0,0)/boot/grub/menu.lst\nquit" | grub --batch --device-map=./device.map

rm ./device.map

