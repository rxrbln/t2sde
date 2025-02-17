dnl --- T2-COPYRIGHT-BEGIN ---
dnl t2/architecture/alpha/linux.conf.m4
dnl Copyright (C) 2004 - 2025 The T2 SDE Project
dnl SPDX-License-Identifier: GPL-2.0
dnl --- T2-COPYRIGHT-END ---

define(`ALPHA', `Alpha AXP')dnl

CONFIG_ALPHA_GENERIC=y
# CONFIG_BINFMT_EM86 is not set

CONFIG_NR_CPUS=2
# ALPHA_EV67

CONFIG_BSD_DISKLABEL=y

include(`linux-common.conf.m4')
include(`linux-block.conf.m4')
CONFIG_BLK_DEV_CY82C693=y

include(`linux-net.conf.m4')
include(`linux-fs.conf.m4')

CONFIG_HZ_256=y
# CONFIG_HZ_1024 is not set

CONFIG_VERBOSE_MCHECK=y

# CONFIG_LOGO_DEC_CLUT224 is not set
