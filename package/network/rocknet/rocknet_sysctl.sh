# --- T2-COPYRIGHT-BEGIN ---
# t2/package/*/rocknet/rocknet_sysctl.sh
# Copyright (C) 2004 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

public_forward() {
	if [ "$if" != "none" ]; then
		error "Keyword >>forward<< not allowed" \
			"in an interface section."
		return
	fi
	[ "$interface" != auto ] && return
	addcode up   9 5 "echo 1 > /proc/sys/net/ipv4/ip_forward"
	addcode down 9 5 "echo 0 > /proc/sys/net/ipv4/ip_forward"
}
