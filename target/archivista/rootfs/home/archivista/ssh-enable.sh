#!/bin/bash

if [ "$UID" -ne 0 ]; then
	exec gnomesu -t "Enable remote access" \
	-m "Please enter the system password (root user)^\
in order to enable remote access (SSH)." -c $0
fi

# PATH and co
. /etc/profile

# keys available?
if ! test -e /etc/ssh/ssh_host_key -o \
          -e /etc/ssh/ssh_host_dsa_key -o \
          -e /etc/ssh/ssh_host_rsa_key
then
	Xdialog --title "SSH setup" --yesno "No host keys present.
Generate private keys now?" 8 28 || exit
	# create keys - reuse stone code - don't care about details
	stone -text sshd <<-EOT
		1

	EOT
fi

rc sshd start

if Xdialog --title "SSH setup" --default-no --yesno \
           "Enable remote access (SSH) permanently?" \
           0 0; then
	ln -sf ../init.d/sshd /etc/rc.d/rc5.d/S25sshd
	ln -sf ../init.d/sshd /etc/rc.d/rc5.d/K75sshd

	Xdialog --title "SSH setup" --msgbox \
	        "Remote access (SSH) enabled permanently." 0 0
else
	Xdialog --title "SSH setup" --msgbox "Remote access (SSH) enabled." 0 0
fi
