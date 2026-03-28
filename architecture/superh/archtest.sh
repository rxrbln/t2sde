# --- T2-COPYRIGHT-BEGIN ---
# t2/architecture/superh/archtest.sh
# Copyright (C) 2004 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

case "$SDECFG_SH_OPT" in
	sh|sh2|sh3|sh4) arch_machine="$SDECFG_SH_OPT" ;;
esac

arch_target="${arch_machine}-t2-linux-gnu"
