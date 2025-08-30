# --- T2-COPYRIGHT-BEGIN ---
# t2/architecture/sparc/linux.conf.sh
# Copyright (C) 2009 - 2025 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

if [ -f $base/architecture/$arch/linux.conf.m4 ]; then
	m4 -I $base/architecture/$arch -I $base/architecture/share $base/architecture/$arch/linux.conf.m4
	[[ "$SDECFG_SPARC_OPT" = leon* ]] &&
		echo "CONFIG_SPARC_LEON=y" || echo "# CONFIG_SPARC_LEON is not set"
fi
