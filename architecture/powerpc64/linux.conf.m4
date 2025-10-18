dnl --- T2-COPYRIGHT-BEGIN ---
dnl t2/architecture/powerpc64/linux.conf.m4
dnl Copyright (C) 2004 - 2025 The T2 SDE Project
dnl SPDX-License-Identifier: GPL-2.0
dnl --- T2-COPYRIGHT-END ---

define(`PPC64', 'PowerPC64')dnl

dnl System type (default=Macintosh)
dnl
CONFIG_PPC=y
# CONFIG_PPC32 is not set
CONFIG_PPC64=y
CONFIG_PPC_BOOK3S_64=y
CONFIG_64BIT=y
CONFIG_6xx=y
# CONFIG_4xx is not set
# CONFIG_82xx is not set
# CONFIG_8xx is not set
CONFIG_PMAC=y
CONFIG_PMAC64=y
CONFIG_PPC_POWERNV=y
CONFIG_PPC_PMAC64=y
CONFIG_PPC_PS3=y
CONFIG_PPC_IBM_CELL_BLADE=y
CONFIG_PPC_PASEMI=y

CONFIG_PPC_PASEMI_IOMMU=y

dnl CONFIG_PPC_64K_PAGES is not set
CONFIG_PPC_4K_PAGES=y

CONFIG_ALTIVEC=y
CONFIG_VSX=y

dnl Platform specific support
dnl

CONFIG_PROC_DEVICETREE=y

CONFIG_ADB=y
CONFIG_ADB_CUDA=y
CONFIG_ADB_PMU=y
CONFIG_PMAC_SMU=y

CONFIG_SERIAL_PMACZILOG=y
CONFIG_SERIAL_PMACZILOG_CONSOLE=y

include(`linux-common.conf.m4')
include(`linux-block.conf.m4')
include(`linux-net.conf.m4')
include(`linux-fs.conf.m4')

CONFIG_HVC_RTAS=y
CONFIG_HVC_UDBG=y

dnl macs need a special RTC ... (this needs to be fixed in the kernel so we
dnl can have generic support for the rs6k and mac support at the same time)
dnl
CONFIG_GEN_RTC=y
CONFIG_PPC_RTC=y

dnl AGP
dnl
CONFIG_AGP_UNINORTH=y

CONFIG_PS3_ADVANCED=y
CONFIG_PS3_PS3AV=m
CONFIG_PS3_SYS_MANAGER=m
CONFIG_PS3_DISP_MANAGER=m
CONFIG_FB=m
CONFIG_FB_PS3=m

dnl power management
dnl
CONFIG_PMAC_PBOOK=y
CONFIG_PMAC_BACKLIGHT=y
CONFIG_PMAC_APM_EMU=y

dnl the thermal control stuff needed for Macs
dnl
CONFIG_I2C=y
CONFIG_I2C_KEYWEST=y
CONFIG_I2C_POWERMAC=y

CONFIG_WINDFARM=m
CONFIG_CPU_FREQ_PMAC64=y

CONFIG_BLK_DEV_IDE_PMAC=y
CONFIG_BLK_DEV_IDE_PMAC_ATA100FIRST=y
CONFIG_BLK_DEV_IDEDMA_PMAC=y
CONFIG_PS3_PARTITION=y
CONFIG_PS3_SYS_MANAGER=m
CONFIG_PS3_DISK=m

CONFIG_BLK_DEV_IDE_PMAC_BLINK=y
CONFIG_PMU_HD_BLINK=y

# CONFIG_MAC_ADBKEYCODES is not set

dnl some network tweaks (the GMAC is obsoleted by SUNGEM)
dnl
# CONFIG_GMAC is not set
CONFIG_SUNGEM=m
CONFIG_GELIC_WIRELESS=y

dnl Console support for IBM PowerVM LPARs
CONFIG_HVC_CONSOLE=y

dnl Allow GRUB to set Open Firmware boot settings
CONFIG_NVRAM=y
