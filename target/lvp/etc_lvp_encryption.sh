#!/bin/bash

if [ -e /lvp.data1 ] ; then
	echo -n "Found "
	for x in /lvp.data* ; do
		echo -n "$x "
	done
	echo
	echo "Starting crypto-subroutine"

	insmod /lib/modules/`uname -r`/block/loop.o >/dev/null 2>/dev/null
	insmod /lib/modules/`uname -r`/block/loop_blowfish.o >/dev/null 2>/dev/null && blowfish=1
	insmod /lib/modules/`uname -r`/block/loop_twofish.o >/dev/null 2>/dev/null && twofish=1
	insmod /lib/modules/`uname -r`/block/loop_serpent.o >/dev/null 2>/dev/null && serpent=1
	echo "Please choose which encryption you want to use:"
	[ "${blowfish}" == 1 ] && echo -e "\t1\tblowfish"
	[ "${twofish}" == 1 ] && echo -e "\t2\ttwofish"
	[ "${serpent}" == 1 ] && echo -e "\t3\tserpent"
	echo
	if [ "${blowfish}" != 1 -a "${twofish}" != 1 -a "${serpent}" != 1 ] ; then
		echo "Couldn't find a usable cipher for encryption." >&2
		echo "Can't mount encrypted data." >&2
		echo "Sorry >_<" >&2
		echo >&2
		read -p "Press -<Enter>- to shut down the system"
		echo 'o' >/proc/sysrq-trigger
	fi
	unset thisenc
	while [ -z "${thisenc}" ] ; do
		echo -n "Please enter your choice: "
		read rthisenc
		[ "${rthisenc}" == "1" -a "${blowfish}" == "1" ] && thisenc="blowfish256"
		[ "${rthisenc}" == "2" -a "${twofish}" == "1" ] && thisenc="twofish256"
		[ "${rthisenc}" == "3" -a "${serpent}" == "1" ] && thisenc="serpent256"
	done
	echo "Using ${thisenc%256} encryption."
	while [ ! -e /mnt1/lvp.xml ] ; do
		umount /mnt* >/dev/null 2>&1
		read -p "Please enter passphrase: " -s passphrase
		echo
		for x in /lvp.data* ; do
			echo "${passphrase}" | mount -o encryption=${thisenc} -p 0 ${x} /mnt${x#/lvp.data} 2>&1
		done
		[ ! -e /mnt1/lvp.xml ] && echo "Wrong Passphrase!"
	done
fi

