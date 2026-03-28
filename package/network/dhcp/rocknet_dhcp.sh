# --- T2-COPYRIGHT-BEGIN ---
# t2/package/*/dhcp/rocknet_dhcp.sh
# Copyright (C) 2004 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

public_dhcp() {
	addcode up   5 1 "ip link set $if up"
	addcode up   5 5 "dhclient -q -pf /var/run/dhclient-$if.pid $@ $if"
	addcode down 5 5 "/sbin/dhclient -pf /var/run/dhclient-$if.pid -x"
}
