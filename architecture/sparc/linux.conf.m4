dnl --- T2-COPYRIGHT-BEGIN ---
dnl t2/architecture/sparc/linux.conf.m4
dnl Copyright (C) 2004 - 2026 The T2 SDE Project
dnl SPDX-License-Identifier: GPL-2.0
dnl --- T2-COPYRIGHT-END ---

define(`SPARC', 'SPARC')dnl

# CONFIG_SUN4 is not set

dnl run on old V7
# CONFIG_MATH_EMULATION=y

include(`linux-common.conf.m4')
include(`linux-block.conf.m4')
include(`linux-net.conf.m4')
include(`linux-fs.conf.m4')

CONFIG_SERIAL_SUNZILOG=y
CONFIG_SERIAL_SUNZILOG_CONSOLE=y
CONFIG_SERIAL_8250=m

CONFIG_SCSI_SUNESP=y

CONFIG_FB=y
CONFIG_FB_SBUS=y
CONFIG_FB_BWTWO=y
CONFIG_FB_BW2=y
CONFIG_FB_CGTHREE=y
CONFIG_FB_CG3=y
CONFIG_FB_CGSIX=y
CONFIG_FB_CG6=y
CONFIG_FB_TCX=y
CONFIG_FB_CGFOURTEEN=y
CONFIG_FB_CG14=y
CONFIG_FB_LEO=y
CONFIG_FB_P9100=y

# CONFIG_FONT_SUN8x16 is not set
# CONFIG_LOGO_SUN_CLUT224 is not set

dnl need to make it small

# CONFIG_SMP is not set
CONFIG_PREEMPT_NONE=y

include(`linux-small.conf.m4')

# CONFIG_PCI is not set
# CONFIG_WIRELESS is not set
# CONFIG_MEDIA_SUPPORT is not set
# CONFIG_VIDEO_V4L2 is not set

# CONFIG_DEBUG_MISC is not set
# CONFIG_FAULT_INJECTION is not set
