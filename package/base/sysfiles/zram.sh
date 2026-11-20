#!/bin/bash
# --- T2-COPYRIGHT-BEGIN ---
# t2/package/*/sysfiles/zram.sh
# Copyright (C) 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

# initialize any /dev/zram*
sed -n 's/#.*//; /zram/p' /etc/fstab |
while read dev mnt typ opt x y; do
    [[ "$typ" != swap || "$dev" != /dev/zram* ]] && continue
    opts=
    for o in ${opt//,/ }; do
	if [[ $o = size=* ]]; then
	    o="${o#size=}"
	    [[ "$o" = *% ]] && # total mem in kB
		mem=$(sed -n 's/MemTotal: *\([0-9]*\).*/\1/p' /proc/meminfo) &&
		opts="-s $(( $mem * ${o//%/} / 100))k"
	fi
    done
    modprobe zram && zramctl $dev $opts && mkswap $dev
done
