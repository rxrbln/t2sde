#!/bin/bash

# Function to create a custom live-cd initrd
mkinitrd()
{
	kernel=$1
	kernelver=$2
	moduledir=$3
	initrd=$4

	echo "Kernel: $kernel Ver: $kernelver Modules: $moduledir"\
	     "Initrd: $initrd"

	cd $build_rock

	# create basic structure
	#
	rm -rf initramfs
	mkdir -p initramfs/{dev,bin,sbin,proc,sys,lib/modules,etc/hotplug.d/default}
	mknod initramfs/dev/console c 5 1

	# copy the basic / rootfs kernel modules
	#
	echo "Copying kernel modules ..."
	find $build_root/$moduledir/kernel -type f | grep \
	    -e reiserfs -e ext2 -e ext3 -e isofs -e /jfs -e /xfs \
	    -e /unionfs -e ntfs -e /dos \
	    -e /ide/ -e /scsi/ -e hci -e usb-storage -e sbp2 |
	while read fn ; do
	  for x in $fn `modinfo $fn | grep depends |
	         cut -d : -f 2- | sed -e 's/ //g' -e 's/,/ /g' `
	  do
		# expand to full name if it was a depend
		[ $x = ${x##*/}  ] &&
		x=`find $build_root/$moduledir/kernel -name "$x.*o"`

		relativ=${x#$build_root/}
		mkdir -p `dirname initramfs/$relativ` 
		cp $x initramfs/$relativ 2>&1 | grep -v omitting
	  done
	done

	# generate map files
	#
	/sbin/depmod  --basedir initramfs $kernelver

	echo "Injecting remaining content ..."

	# copying config
	#
	cp -ar $build_root/etc/udev initramfs/etc/

	# setup programs
	#
	cp $build_root/sbin/{hotplug++,udev,udevstart,modprobe,insmod} \
	   initramfs/sbin/
	ln -sf /sbin/udev initramfs/etc/hotplug.d/default/10-udev.hotplug

	cp $build_root/bin/pdksh initramfs/bin/sh
	cp $build_root/usr/embutils/{mount,umount,rm,mv,mkdir,ls,ln,\
pivot_root,sleep,losetup,chmod,cat} initramfs/bin/
	ln -s mv initramfs/bin/cp

	echo "root:x:0:0:root:/:/bin/sh" > initramfs/etc/passwd

	# TODO: do we need this target specific?
	cp $base/target/livecd/{init,init2} initramfs/

	# create the cpio image
	#
	echo "Archiving ..."
	( cd initramfs
	  find * | cpio -o -H newc | gzip -9 > ../$initrd
	)

	# display the resulting image
	#
	du -sh $initrd
}

# For each available kernel:
#
for x in `egrep 'X .* KERNEL .*' $base/config/$config/packages |
          cut -d ' ' -f 5` ; do

  kernel=${x/_*/}
  moduledir="`grep lib/modules  $build_root/var/adm/flists/$kernel |
              cut -d ' ' -f 2 | cut -d / -f 1-3 | uniq | head -n 1`"
  kernelver=${moduledir/*\/}
  initrd="initrd${kernel/linux/}.gz"
  mkinitrd $kernel $kernelver $moduledir $initrd
done

