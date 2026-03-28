# --- T2-COPYRIGHT-BEGIN ---
# t2/package/*/linux-igd/rocknet_upnp.sh
# Copyright (C) 2008 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

public_upnp() {
	addcode up   5 5 "/usr/sbin/upnpd $1 $2"
	addcode down 5 5 "killall -TERM upnpd"
}
