dnl --- T2-COPYRIGHT-BEGIN ---
dnl t2/architecture/m68k/linux.conf.m4
dnl Copyright (C) 2004 - 2026 The T2 SDE Project
dnl SPDX-License-Identifier: GPL-2.0
dnl --- T2-COPYRIGHT-END ---

define(`M68K', 'M68K')dnl

dnl CONFIG_M68020=y
CONFIG_M68030=y
CONFIG_M68040=y
CONFIG_M68060=y

CONFIG_AMIGA=y
CONFIG_ATARI=y
CONFIG_MAC=y
# CONFIG_APOLLO is not set
# CONFIG_VME is not set
# CONFIG_HP300 is not set
CONFIG_SUN3X=y
# CONFIG_Q40 is not set

CONFIG_NUBUS=y
CONFIG_ZORRO=y

include(`linux-common.conf.m4')
include(`linux-block.conf.m4')
include(`linux-net.conf.m4')
include(`linux-fs.conf.m4')

# CONFIG_FONT_PEARL_8x8 is not set
# CONFIG_FONT_6x11 is not set

CONFIG_AMIGA_BUILTIN_SERIAL=y

CONFIG_SERIAL_PMACZILOG=y
CONFIG_SERIAL_PMACZILOG_TTYS=y
CONFIG_SERIAL_PMACZILOG_CONSOLE=y
# CONFIG_SERIAL_8250 is not set

CONFIG_FB=y
CONFIG_FB_VALKYRIE=y
CONFIG_FB_MAC=y
