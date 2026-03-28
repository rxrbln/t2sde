# --- T2-COPYRIGHT-BEGIN ---
# t2/package/*/rocknet/rocknet_script.sh
# Copyright (C) 2004 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

public_script() {
	local a="$1"; shift
	addcode up   5 5 "$a up   $*"
	addcode down 5 5 "$a down $*"
}

public_run_up() {
	addcode up   5 5 "$*"
}

public_run_down() {
	addcode down 5 5 "$*"
}

public_code() {
	addcode $1 $2 5 "$3"
}
