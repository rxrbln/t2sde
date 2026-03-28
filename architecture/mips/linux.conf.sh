# --- T2-COPYRIGHT-BEGIN ---
# t2/architecture/mips/linux.conf.sh
# Copyright (C) 2013 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

{
	[ "$SDECFG_MIPS_ENDIANESS" = "EL" ] &&
		echo "CONFIG_CPU_LITTLE_ENDIAN=y" ||
		echo "CONFIG_CPU_BIG_ENDIAN=y" ||

	echo
	cat <<- 'EOT'
 		include(`linux.conf.m4')
	EOT
} | m4 -I $base/architecture/$arch -I $base/architecture/share
