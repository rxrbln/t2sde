# --- T2-COPYRIGHT-BEGIN ---
# t2/package/*/dhcpcd/rocknet_dhcpcd.sh
# Copyright (C) 2004 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

public_dhcpcd() {
	local pidfile=/var/run/dhcpcd-$if.pid
	if [ -f $pidfile ]; then
		addcode up   5 4 "[ -f $pidfile -a ! -d /proc/\$( cat $pidfile ) ] && rm -f $pidfile"
		addcode down 5 4 "rm -f $pidfile"
	fi
	addcode up   5 5 "/sbin/dhcpcd -h $( hostname ) $if"
	addcode down 5 5 "[ -f $pidfile ] && kill -15 \$( cat $pidfile )"
}
