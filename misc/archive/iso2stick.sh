#!/bin/bash

set -e

usage()
{
	echo "Usage iso2stick [ -fs file-system ] iso-image stick-device [ files ]"
	exit
}

fs="vfat -F 32"

while [ "$1" ]; do
	case "$1" in 
		-fs) fs="$2" ; shift ;;
		-*) usage ;;
		*) break ;;
	esac
	shift
done

if [ -z "$1" -o -z "$2" ]; then
	usage
fi

file="$1" ; shift
dev="$1" ; shift

# # ceate fresh image
# size=`du --block-size=1000000 $1 | cut -f 1`
# size=$(( size + 20 )) # just to be sure
# 
# dd if=/dev/zero of=hd.img bs=1000000 count=$size

# loop=`losetup -f`
# losetup $loop hd.img

case "$fs" in
	vfat*) ptype=b ;;
	*) ptype=83 ;;
esac

sfdisk $dev << EOT
,,$ptype
EOT

# losetup -d $loop

mkfs.$fs ${dev}1

# losetup /dev/loop0 -o 512 hd.img

mkdir -p /mnt/source /mnt/target
mount -o loop $file /mnt/source
mount ${dev}1 /mnt/target

rsync -arvH --inplace --exclude TRANS.TBL /mnt/source/ /mnt/target/
# copy additional content specified in arguments
for x ; do
	cp -arv $x /mnt/target/
done

sed -i 's/(cd)/(hd0,0)/g' /mnt/target/boot/grub/menu.lst

umount /mnt/source
umount /mnt/target

echo -e "(hd0)	/dev/sda" > device.map
echo -e "root (hd0,0)\ninstall /boot/grub/stage1 (hd0) (hd0,0)/boot/grub/stage2 (hd0,0)/boot/grub/menu.lst\nquit" | grub --batch --device-map=./device.map

rm ./device.map

