# --- T2-COPYRIGHT-BEGIN ---
# t2/architecture/sparc64/linux.conf.sh
# Copyright (C) 2009 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

if [ -f $base/architecture/$arch/linux.conf.m4 ]; then
	m4 -I $base/architecture/$arch -I $base/architecture/share $base/architecture/$arch/linux.conf.m4
	[ "$SDECFG_SPARC64_32BIT" = 1 ] &&
		echo "CONFIG_NR_CPUS=8" || echo "CONFIG_NR_CPUS=1024"
fi
