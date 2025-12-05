dnl --- T2-COPYRIGHT-BEGIN ---
dnl t2/architecture/share/linux-debug.conf.m4
dnl Copyright (C) 2025 The T2 SDE Project
dnl SPDX-License-Identifier: GPL-2.0
dnl --- T2-COPYRIGHT-END ---

CONFIG_DEBUG_KERNEL=y
# CONFIG_STRICT_KERNEL_RWX is not set
CONFIG_FRAME_POINTER=y
CONFIG_KGDB=y
CONFIG_KGDB_SERIAL_CONSOLE=y

dnl CONFIG_KGDB_KDB=y
dnl CONFIG_KDB_KEYBOARD=y
