# --- T2-COPYRIGHT-BEGIN ---
# t2/architecture/arm64/linux.conf.sh
# Copyright (C) 2009 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

if [ -f .config.defconfig ]; then
	cat .config.defconfig
elif [ -f $base/architecture/$arch/linux.conf.m4 ]; then
	m4 -I $base/architecture/$arch -I $base/architecture/share $base/architecture/$arch/linux.conf.m4
else
	echo "# No defaults found"
fi
