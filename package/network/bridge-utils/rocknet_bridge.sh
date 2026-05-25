# --- T2-COPYRIGHT-BEGIN ---
# t2/package/*/bridge-utils/rocknet_bridge.sh
# Copyright (C) 2008 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

public_bridge() {
	addcode up 2 5 "brctl addbr $if"
	for i; do
		addcode up 3 5 "ip link set $i up"
		addcode up 3 6 "brctl addif $if $i"
	done

	# interfaces are implicitly removed from the bridge on delbr
	addcode down 1 1 "brctl delbr $if"
}
