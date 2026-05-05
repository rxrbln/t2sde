#!/bin/bash
# --- T2-COPYRIGHT-BEGIN ---
# t2/package/*/sysfiles/hostname.sh
# Copyright (C) 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

hostname="hostname= $(cat /proc/cmdline 2>/dev/null)"
hostname=${hostname##*hostname=} hostname=${hostname%% *}
[ "$hostname" ] || hostname=$(cat /etc/hostname 2>/dev/null)

if [ ! "$hostname" ]; then
    # try DMI first
    [ -e /sys/devices/virtual/dmi/id ] &&
    for f in product_family product_name board_name; do
	hostname=$(cat /sys/devices/virtual/dmi/id/$f 2>/dev/null)
	case "$hostname" in
	*"To Be Filled"*|*Default*|"N/A"|NULL)
		hostname= ;;
	esac
	[ "${hostname// /}" ] && break
    done
    # OF second
    if [ ! "$hostname" -a -e /proc/device-tree ]; then
	hostname=$(sed "s/\x0//" /proc/device-tree/name 2>/dev/null)
	[ "$hostname" ] || hostname=$(sed "s/\x0//" /proc/device-tree/model 2>/dev/null)
	[ "$hostname" ] || hostname=$(sed "s/\x0//" /proc/device-tree/banner-name 2>/dev/null)
    fi
    # try various /proc as fallback
    [ "$hostname" ] || hostname=$(sed -n "/\(system type\)[^:]*:[[:space:]]/{s///p;q}" /proc/cpuinfo)
    [ "$hostname" ] || hostname=$(sed -n "/\(model name\)[^:]*:[[:space:]]/{s///p;q}" /proc/cpuinfo)
    [ "$hostname" ] || hostname=$(sed -n "/\(model\)[^:]*:[[:space:]]/{s///p;q}" /proc/cpuinfo)
    hostname="${hostname%%(*}"
    hostname="${hostname%${hostname##*[![:space:]]}}"
    hostname="${hostname//[[:space:][:punct:]]/_}"
    hostname="${hostname//_/-}"
    hostname="${hostname//--/-}"
fi

[ "$hostname" ] && hostname "$hostname"
