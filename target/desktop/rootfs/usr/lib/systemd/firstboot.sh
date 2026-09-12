#!/bin/bash
# --- T2-COPYRIGHT-BEGIN ---
# t2/target/desktop/rootfs/usr/lib/systemd/firstboot.sh
# Copyright (C) 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

. /etc/profile

echo "Running firstboot services"
for p in /etc/postinstall.d/*; do
	echo $p
	$p >/dev/null 2>&1
done

[[ "$(uname -m)" != *86* ]] &&
	systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

[ ! -e /dev/dri/card0 ] &&
	systemctl disable plasmalogin.service --now

mem=$(sed -n '/MemTotal/{s/.* \([[:digit:]]*\) .*/\1/p}' /proc/meminfo)
if [ $mem -le $((1024* 1024)) ]; then
	modprobe zram
	zram=$(zramctl -f -s $((mem/8))k)
	mkswap $zram
	swapon $zram -p 200
fi

if type -p localedef >/dev/null 2>&1; then
    set +m
    maxjobs=$(nproc)
    for l in C.UTF-8; do
	echo -n "$l "
	localedef -i ${l%.*} -c -f ${l#*.} $l &
	if [ $((--maxjobs)) -le 0 ]; then
		wait -n
		((++maxjobs))
	fi
    done
fi

echo

useradd -u 1000 user -G audio,input,kvm,video,wheel 2>/dev/null
su user -c "xdg-user-dirs-update"
chpasswd <<-EOT
root:password
user:password
EOT

wait
