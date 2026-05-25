dnl --- T2-COPYRIGHT-BEGIN ---
dnl t2/architecture/superh/linux.conf.m4
dnl Copyright (C) 2004 - 2026 The T2 SDE Project
dnl SPDX-License-Identifier: GPL-2.0
dnl --- T2-COPYRIGHT-END ---

define(`SH', `SUPERH')dnl

include(`linux-common.conf.m4')
include(`linux-block.conf.m4')
include(`linux-net.conf.m4')
include(`linux-fs.conf.m4')

dnl just disable after defconf
# CONFIG_CMDLINE_OVERWRITE it not set

dnl unresolved symbol
# CONFIG_AIR_EN8811H_PHY is not set
