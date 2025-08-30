# --- T2-COPYRIGHT-BEGIN ---
# t2/architecture/sparc/archtest.sh
# Copyright (C) 2004 - 2025 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

case "$SDECFG_SPARC_OPT" in
    *) arch_machine="sparc" ;;
    v8) arch_machine="sparcv8" ;;
    v9) arch_machine="sparcv9" ;;
    v9vis) arch_machine="sparcv9b" ;;
esac

arch_target="${arch_machine}-t2-linux-gnu"
