dnl --- T2-COPYRIGHT-BEGIN ---
dnl t2/architecture/mips/linux.conf.m4
dnl Copyright (C) 2004 - 2026 The T2 SDE Project
dnl SPDX-License-Identifier: GPL-2.0
dnl --- T2-COPYRIGHT-END ---

define(`MIPS', `MIPS')dnl

CONFIG_MIPS=y
CONFIG_MIPS32=y

# CONFIG_MIPS_GENERIC_KERNEL is not set
CONFIG_MIPS_MALTA=y

include(`linux-common.conf.m4')
include(`linux-block.conf.m4')
include(`linux-net.conf.m4')
include(`linux-fs.conf.m4')

# CONFIG_LOGO_SGI_CLUT224 is not set
