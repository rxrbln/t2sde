dnl --- T2-COPYRIGHT-BEGIN ---
dnl t2/architecture/loongarch64/linux.conf.m4
dnl Copyright (C) 2004 - 2026 The T2 SDE Project
dnl SPDX-License-Identifier: GPL-2.0
dnl --- T2-COPYRIGHT-END ---

define(`LOONGARCH64', 'LOONGARCH64')dnl

include(`linux-common.conf.m4')
include(`linux-block.conf.m4')
include(`linux-net.conf.m4')
include(`linux-fs.conf.m4')

# CONFIG_ACPI_PROCESSOR is not set

CONFIG_KEYBOARD_ATKBD=m
CONFIG_SERIO=m
