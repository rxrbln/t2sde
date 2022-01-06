#!/bin/sh

kernel=`uname -r`
tmpdir=`mktemp -d`
empty=0

if [ "$1" = "empty" ]; then
	empty=1; shift
fi

if [ -n "$1" ]; then
	if [ -d "/lib/modules/$1" ]; then
		kernel="$1"
	else
		echo "Can't open /lib/modules/$1: No such directory."
		echo "Usage: $0 [ kernel-version ]"
		exit 1
	fi
fi

cat << 'EOT' > $tmpdir/linuxrc.c
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <stdio.h>

int main()
{
EOT

echo "Creating /boot/initrd-${kernel}.img ..."
if [ "$empty" = 0 ]; then
  grep '^modprobe ' /etc/conf/kernel |
  grep -v 'no-initrd' | sed 's,[ 	]#.*,,' |
  while read a b; do $a -n -v $b 2> /dev/null; done |
  while read a b c; do
	# ouch - this is pretty ugly....
	b="${b//`uname -r`/$kernel}"
	if [ ! -f $tmpdir/${b##*/} ]; then
		echo "Adding $b."; cp $b $tmpdir
		x="$( eval "echo ${b##*/} $c" )"
		cat << EOT >> $tmpdir/linuxrc.c
	/* $x */
	if ( fork() ) wait(NULL);
	else {
		printf("initrd: loading %s.\n", "$x"); fflush(stdout);
		execl("/insmod.static", "/insmod.static", "${x// /", "}", NULL);
		_exit(1);
	}
EOT
	fi
  done
fi
echo -e '\tprintf("initrd: going to re-mount root now.\\n");' >> $tmpdir/linuxrc.c
echo -e '\treturn 0;\n}' >> $tmpdir/linuxrc.c
gcc -s -static -Wall -Os -o $tmpdir/linuxrc $tmpdir/linuxrc.c
cp /sbin/insmod.static* $tmpdir/
if [ -f $tmpdir/insmod.static.old ]; then
	ln -s insmod.static.old $tmpdir/insmod.old
fi
mkdir -p $tmpdir/dev
mknod $tmpdir/dev/null    c 1 3
mknod $tmpdir/dev/zero    c 1 5
mknod $tmpdir/dev/tty     c 5 0
mknod $tmpdir/dev/console c 5 1

if false; then
	# FIXME: kernel doesn't like romfs as initrd ?!?!
	genromfs -f /boot/initrd-${kernel}.img.tmp -d $tmpdir
else
	# This works, but only for initrd images < 4 MB
	dd if=/dev/zero of=/boot/initrd-${kernel}.img.tmp \
				count=4096 bs=1024 &> /dev/null
	mke2fs -m 0 -N 180 -F /boot/initrd-${kernel}.img.tmp &> /dev/null
	mntpoint="`mktemp -d`"
	mount -o loop /boot/initrd-${kernel}.img.tmp $mntpoint
	rmdir $mntpoint/lost+found/
	cp -a $tmpdir/* $mntpoint/
	umount $mntpoint
	rmdir $mntpoint
fi
gzip < /boot/initrd-${kernel}.img.tmp > /boot/initrd-${kernel}.img
rm -f /boot/initrd-${kernel}.img.tmp

rm -rf $tmpdir
echo "Done."

