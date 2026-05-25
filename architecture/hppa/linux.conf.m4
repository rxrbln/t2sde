dnl --- T2-COPYRIGHT-BEGIN ---
dnl t2/architecture/hppa/linux.conf.m4
dnl Copyright (C) 2004 - 2026 The T2 SDE Project
dnl SPDX-License-Identifier: GPL-2.0
dnl --- T2-COPYRIGHT-END ---

# CONFIG_SMP is not set

CONFIG_PA7000=y
dnl CONFIG_PA8X00 is not set

CONFIG_PCI_MESON=y
CONFIG_GSC_DINO=y
CONFIG_PCI_LBA=y
CONFIG_IOMMU_CCIO=y

CONFIG_HPPB=y
CONFIG_GSC_LASI=y
CONFIG_EISA=y
CONFIG_GSC_WAX=y
CONFIG_PCCARD=m

include(`linux-common.conf.m4')
include(`linux-block.conf.m4')
include(`linux-net.conf.m4')
include(`linux-fs.conf.m4')

CONFIG_PDC_CONSOLE=y
CONFIG_FB_STI=y

# CONFIG_LOGO_PARISC_CLUT224 is not set
