# --- T2-COPYRIGHT-BEGIN ---
# t2/package/*/wireguard-tools/rocknet_wireguard.sh
# Copyright (C) 2021 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

public_wg_quick() {
	addcode up 2 5 "wg-quick up $if"
	addcode down 2 5 "wg-quick down $if"
}
