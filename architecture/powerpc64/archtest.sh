# --- T2-COPYRIGHT-BEGIN ---
# t2/architecture/powerpc64/archtest.sh
# Copyright (C) 2004 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

case "$SDECFG_POWERPC64_ENDIANESS" in
    le)
	arch_bigendian=no
	arch_machine="${arch_machine/powerpc64/powerpc64le}"
	arch_target="${arch_target/powerpc64/powerpc64le}"
	;;
esac
