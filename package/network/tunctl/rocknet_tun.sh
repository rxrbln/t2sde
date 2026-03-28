# --- T2-COPYRIGHT-BEGIN ---
# t2/package/*/tunctl/rocknet_tun.sh
# Copyright (C) 2012 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

public_tun() {
	addcode up 2 5 "tunctl -u root -t  $if"
}
