dnl --- T2-COPYRIGHT-BEGIN ---
dnl t2/architecture/ia64/linux.conf.m4
dnl Copyright (C) 2004 - 2025 The T2 SDE Project
dnl SPDX-License-Identifier: GPL-2.0
dnl --- T2-COPYRIGHT-END ---

define(`IA64', 'ITANIUM')dnl

CONFIG_IA64_PAGE_SIZE_16KB=y

dnl System type

dnl dynamic w/ _ITANIUM, but gcc can no longer tune for v1 since gcc-4.5
# CONFIG_ITANIUM is not set
CONFIG_MCKINLEY=y

CONFIG_IA64_MCA_RECOVERY=y

include(`linux-common.conf.m4')
include(`linux-block.conf.m4')
include(`linux-net.conf.m4')
include(`linux-fs.conf.m4')

CONFIG_NR_CPUS=16

dnl ld: arch/ia64/kernel/efi.o: in function `efi_initialize_iomem_resources':
dnl efi.c:(.text+0x2db1): undefined reference to `crashk_res' ...
# CONFIG_KEXEC is not set
