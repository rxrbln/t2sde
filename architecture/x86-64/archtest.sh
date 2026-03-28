# --- T2-COPYRIGHT-BEGIN ---
# t2/architecture/x86-64/archtest.sh
# Copyright (C) 2016 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

[ "$SDECFG_X8664_X32" = 1 ] &&
	arch_sizeof_long=4 && arch_sizeof_char_p=4 &&
	arch_target="${arch_target}x32"
