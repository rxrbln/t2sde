#!/bin/sh

if [ "$1" = -combo ] ; then
	combo=1
elif [ "$#" != 0 ] ; then
	echo "usage: $0 [-combo]"
	exit 1
fi

tmpfile=`mktemp -p $PWD`
tmpdir=$tmpfile.dir
mkdir $tmpdir || exit 1
rc=0

tmpdev=""
for x in /dev/loop/* ; do
	if losetup $x $tmpfile 2> /dev/null ; then
		tmpdev=$x ; break
	fi
done
if [ -z "$tmpdev" ] ; then
	echo "No free loopback device found!"
	rm -f $tmpfile ; rmdir $tmpdir
	exit 1
fi
echo "Using $tmpdev."

for image in initrd boot_144 boot_288
do
	echo "Creating ${image}.img ..."

	case ${image} in
		initrd)
			size=4096 ;;
		boot_144)
			size=1440 ;;
		boot_288)
			size=2880 ;;
	esac

	dd if=/dev/zero of=$tmpfile bs=1024 count=$size &> /dev/null
	losetup -d $tmpdev ; losetup $tmpdev $tmpfile || rc=1
	mke2fs -q $tmpdev &> /dev/null ; mount $tmpdev $tmpdir || rc=1

	case ${image} in
		initrd)
			cp -a initrd/* $tmpdir || rc=1
			;;

		boot_144|boot_288)
			cp -a boot/{vmlinuz,lilo-help.txt} $tmpdir || rc=1
			if [ -f /boot/boot-text.b ]; then
				cp /boot/boot-text.b $tmpdir/boot.b || rc=1
			fi
			liloconf=lilo-conf-${image#boot_}
			if [ $image = boot_288 -o "$combo" = 1 ] ; then
				cp initrd.img $tmpdir || rc=1
				[ $image = boot_144 ] && liloconf=lilo-conf-1x2
			fi
			sed -e "s,/mnt/,$tmpdir/,g" \
			    -e "s,/dev/floppy/0,$tmpdev,;" \
				< boot/$liloconf > $tmpdir/lilo.conf || rc=1
			lilo -C $tmpdir/lilo.conf > /dev/null || rc=1
			;;
	esac

	umount $tmpdir

	case ${image} in
		initrd)	gzip -9 < $tmpfile > $image.img || rc=1 ;;
		*)	cp $tmpfile $image.img || rc=1 ;;
	esac
done

losetup -d $tmpdev
rm -f $tmpfile
rmdir $tmpdir

exit $rc

