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

maxcpu=`get_max_cpu /boot/grub/menu.lst`

if [ $maxcpu = 0 ]; then
	Xdialog --title "Multi CPU" --yesno "Enable multi CPU (SMP) support?" 0 0 || exit
	maxcpu=8
else
	Xdialog --title "Multi CPU" --yesno "Disable multi CPU (SMP) support?" 0 0 || exit
	maxcpu=0
fi

set_max_cpu /boot/grub/menu.lst $maxcpu

Xdialog --title "Multi CPU" --msgbox "The setting was saved and will
have effect on the next reboot." 0 0
