# --- T2-COPYRIGHT-BEGIN ---
# t2/architecture/arm/archtest.sh
# Copyright (C) 2007 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

case "$SDECFG_ARM_OPT" in
	arm7*)
		arch_machine=${arch_machine}v4 ;;
	arm[89]*|arm10*)
		arch_machine=${arch_machine}v5 ;;
	arm11*)
		arch_machine=${arch_machine}v6 ;;
	armv*)
		arch_machine=${SDECFG_ARM_OPT%-*} ;;
	*)
		arch_machine=${arch_machine}v7 ;;
esac

if [ "$SDECFG_ARM_ENDIANESS" = "eb" ]; then
	arch_bigendian=yes
	arch_machine=${arch_machine}eb
fi

arch_target="${arch_machine}-t2-linux-${SDECFG_ARM_ABI}"
[ "$SDECFG_SOFTFLOAT" = 1 ] || arch_target="${arch_target}hf"
