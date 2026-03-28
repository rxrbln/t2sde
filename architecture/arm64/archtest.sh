# --- T2-COPYRIGHT-BEGIN ---
# t2/architecture/arm64/archtest.sh
# Copyright (C) 2007 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

case "$SDECFG_ARM64_ENDIANESS" in
	eb)
		arch_bigendian=yes
		arch_machine=aarch64_eb ;;
		
	*)
		arch_bigendian=no
		arch_machine=aarch64 ;;
esac

arch_target="${arch_machine}-t2-linux-gnu"
