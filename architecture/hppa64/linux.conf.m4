dnl --- T2-COPYRIGHT-BEGIN ---
dnl t2/architecture/hppa64/linux.conf.m4
dnl Copyright (C) 2004 - 2025 The T2 SDE Project
dnl SPDX-License-Identifier: GPL-2.0
dnl --- T2-COPYRIGHT-END ---

CONFIG_PA8X00=y
CONFIG_64BIT=y
CONFIG_SMP=y

# CONFIG_GSC is not set
dnl # CONFIG_CPU_ISOLATION is not set

CONFIG_MLONGCALLS=y

CONFIG_HUGETLBFS=y

CONFIG_PCI_MESON=y
CONFIG_GSC_DINO=y
CONFIG_PCI_LBA=y
CONFIG_IOMMU_CCIO=y

CONFIG_HPPB=y
CONFIG_LASI_82596=y
CONFIG_GSC_WAX=y
CONFIG_PCCARD=m

CONFIG_AGP=y
CONFIG_AGP_PARISC=y

include(`linux-common.conf.m4')
include(`linux-block.conf.m4')
include(`linux-net.conf.m4')
include(`linux-fs.conf.m4')

CONFIG_NR_CPUS=4

# CONFIG_CHECKPOINT_RESTORE is not set

CONFIG_PDC_CONSOLE=y
CONFIG_FB=m
CONFIG_FB_STI=m

CONFIG_IPMI_HANDLER=y
CONFIG_IPMI_POWEROFF=y

# CONFIG_LOGO_PARISC_CLUT224 is not set

dnl gcc-13.2 ICE
# CONFIG_MWIFIEX is not set

dnl "__multi3" [fs/bcachefs/bcachefs.ko] undefined!
# CONFIG_BCACHEFS_FS is not set
