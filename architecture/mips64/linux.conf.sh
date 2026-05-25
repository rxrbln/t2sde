# --- T2-COPYRIGHT-BEGIN ---
# t2/architecture/mips64/linux.conf.sh
# Copyright (C) 2013 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

{
	[ "$SDECFG_MIPS64_ENDIANESS" = "EL" ] &&
		echo "CONFIG_CPU_LITTLE_ENDIAN=y" ||
		echo "CONFIG_CPU_BIG_ENDIAN=y"

 	echo "include(\`linux.conf.m4')"

	if [ "$1" ]; then
		echo "# CONFIG_OF is not set"
		echo "include(\`linux.conf.$1')"
	fi
} | m4 -I $base/architecture/$arch -I $base/architecture/mips -I $base/architecture/share
