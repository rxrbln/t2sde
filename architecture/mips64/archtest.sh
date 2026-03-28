# --- T2-COPYRIGHT-BEGIN ---
# t2/architecture/mips64/archtest.sh
# Copyright (C) 2004 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

case "$SDECFG_MIPS64_ENDIANESS" in
    EL)
    	arch_bigendian=no
	arch_target="mips64el-t2-linux" ;;
    EB)
    	arch_bigendian=yes
	arch_target="mips64-t2-linux" ;;
esac

if [ "$SDECFG_MIPS64_N32" = 1 ]; then
	arch_sizeof_long=4 && arch_sizeof_char_p=4
	arch_target="${arch_target}-gnuabin32"
else
	arch_target="${arch_target}-gnuabi64"
fi
