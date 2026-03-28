# --- T2-COPYRIGHT-BEGIN ---
# t2/architecture/x86/archtest.sh
# Copyright (C) 2004 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

case "$SDECFG_X86_OPT" in
    i?86)
	arch_machine="$SDECFG_X86_OPT" ;;

    pentium|pentium-mmx|k6*|c3*)
	arch_machine="i586" ;;

    *)	# all the rest, incuding athlon*, prescot, nocona, etc.
	arch_machine="i686" ;;
esac

arch_target="${arch_machine}-t2-linux-gnu"

if [ "$SDECFG_KERNEL" == "mingw" ]; then
	# TODO: make dynamic, coordinate with architectures
	arch_target=$arch_machine-pc-mingw32
fi
