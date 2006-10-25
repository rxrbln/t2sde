#!/bin/bash

if [ "$UID" -ne 0 ]; then
	exec gnomesu -t "Multi CPU (SMP) configuration" \
	-m "Please enter the system password (root user)^\
in order to configure Multi CPU (SMP) support." -c $0
fi

# PATH and co
. /etc/profile

# include shared code
. ${0%/*}/multi-cpu.in

maxcpus=`get_max_cpus /boot/grub/menu.lst`

if [ $maxcpus = 0 ]; then
	Xdialog --title "Multi CPU" --yesno "Enable multi CPU (SMP) support?" 0 0 || exit
	maxcpus=8
else
	Xdialog --title "Multi CPU" --yesno "Disable multi CPU (SMP) support?" 0 0 || exit
	maxcpus=0
fi

set_max_cpus /boot/grub/menu.lst $maxcpus

Xdialog --title "Multi CPU" --msgbox "The setting was saved and will
have effect on the next reboot." 0 0
