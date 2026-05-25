# --- T2-COPYRIGHT-BEGIN ---
# t2/package/*/silo/stone_mod_silo.sh
# Copyright (C) 2004 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---
#
# [MAIN] 70 silo SILO Boot Loader Setup
# [SETUP] 90 silo

create_kernel_list() {
	local first=1
	for x in `(cd /boot/; ls vmlinuz-*) | sort -Vr`; do
		if [ $first = 1 ]; then
			label=linux first=0
		else
			label=linux-${x/vmlinuz-/}
		fi
		ver=${x/vmlinuz-}
		cat << EOT

image=$bootpath/$x
	label=$label
	root=$rootdev
	initrd=$bootpath/initrd-${ver}
	read-only
EOT
	done
}

create_silo_conf() {
	cat << EOT > /boot/silo.conf

# /boot/silo.conf created with the T2 SDE SILO STONE module

root=$bootdev

# Second silo image chooser delay
timeout=80

EOT

	create_kernel_list >> /boot/silo.conf

	gui_message "This is the new /boot/silo.conf file:

$( cat /boot/silo.conf )"
}

silo_install()
{
	gui_cmd 'Installing SILO' "echo 'calling silo'; silo -C /boot/silo.conf"
}

device4()
{
	local dev="`grep \" $1 \" /proc/mounts | tail -n 1 |
	            cut -d ' ' -f 1`"
	if [ ! "$dev" ]; then # try the higher dentry
		local try="`dirname $1`"
		dev="`grep \" $try \" /proc/mounts | tail -n 1 | \
		      cut -d ' ' -f 1`"
	fi
	if [ -h "$dev" ]; then
	  echo "/dev/`readlink $dev`"
	else
	  echo $dev
	fi
}

realpath() {
	dir="`dirname $1`"
	file="`basename $1`"
	dir="`dirname $dir`/`readlink $dir`"
	dir="`echo $dir | sed 's,[^/]*/\.\./,,g'`"
	echo $dir/$file
}

main() {
	rootdev="`device4 /`"
	bootdev="`device4 /boot`"

	if [ "$rootdev" = "$bootdev" ]
	then bootpath=/boot; else bootpath=""; fi

	if [ ! -f /boot/silo.conf ]; then
	  if gui_yesno "SILO does not appear to be configured.
Automatically install SILO now?"; then
	    create_silo_conf
	    if ! silo_install; then
	      gui_message "There was an error while installing SILO."
	    fi
	  fi
	fi

	while

	gui_menu yaboot 'SILO Boot Loader Setup' \
		"Root Device ........... $rootdev" "" \
		"Boot Device ........... $bootdev" "" \
		"Boot Path ............. $bootpath" "" \
		'' '' \
		'(Re-)Create silo.conf with installed kernels' 'create_silo_conf' \
		'(Re-)Install SILO' 'silo_install' \
		'' '' \
		"Edit /boot/silo.conf (Config file)" \
			"gui_edit 'STONE Configuration' /boot/silo.conf"
    do : ; done
}
