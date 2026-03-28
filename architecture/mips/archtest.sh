# --- T2-COPYRIGHT-BEGIN ---
# t2/architecture/mips/archtest.sh
# Copyright (C) 2004 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

case "$SDECFG_MIPS_ENDIANESS" in
    EL)
	arch_bigendian=no
	arch_target="mipsel-t2-linux-gnu" ;;
    EB)
	arch_bigendian=yes
	arch_target="mips-t2-linux-gnu" ;;
esac
