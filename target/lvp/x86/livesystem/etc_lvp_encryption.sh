#!/bin/bash

if [ -e /lvp.data1 ] ; then
	echo -n "Found "
	for x in /lvp.data* ; do
		echo -n "$x "
	done
	echo
	echo "Starting crypto-subroutine"

	echo "Please choose which encryption you want to use:"
	echo -e "\t1\tblowfish"
	echo -e "\t2\ttwofish"
	echo -e "\t3\tserpent"
	echo
	unset thisenc
	while [ -z "${thisenc}" ] ; do
		read -p "Please enter your choice: " rthisenc
		[ "${rthisenc}" == "1" ] && thisenc="blowfish256"
		[ "${rthisenc}" == "2" ] && thisenc="twofish256"
		[ "${rthisenc}" == "3" ] && thisenc="serpent256"
	done
	echo "Using ${thisenc%256} encryption."
	while [ ! -e /mnt1/lvp.xml ] ; do
		read -p "Please enter passphrase: " -s passphrase
		echo
		exec 2>/dev/null
		for x in /lvp.data* ; do
			echo "${passphrase}" | losetup -e ${thisenc} -p 0 /dev/loop/${x#/lvp.data} ${x} 
			mount /dev/loop/${x#/lvp.data} /mnt${x#/lvp.data} 2>&1
		done
		if [ ! -e /mnt1/lvp.xml ] ; then
			echo "Wrong Passphrase!"
			for x in /lvp.data* ; do
				losetup -d /dev/loop/${x#/lvp.data}
			done
		fi
		exec 2>&1
	done
fi

