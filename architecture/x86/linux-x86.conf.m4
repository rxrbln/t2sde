dnl --- T2-COPYRIGHT-BEGIN ---
dnl t2/architecture/x86/linux-x86.conf.m4
dnl Copyright (C) 2009 - 2025 The T2 SDE Project
dnl SPDX-License-Identifier: GPL-2.0
dnl --- T2-COPYRIGHT-END ---

CONFIG_SFI=y

dnl Memory Type Range Register support
dnl and other x86 goodies ...
dnl
CONFIG_MTRR=y
CONFIG_X86_MCE=y
CONFIG_X86_MCE_NONFATAL=y
CONFIG_X86_MCE_P4THERMAL=y
CONFIG_INTEL_IDLE=y

CONFIG_X86_X2APIC=y
CONFIG_MICROCODE_AMD=y

CONFIG_INPUT_PCSPKR=m
CONFIG_USB_HIDINPUT_POWERBOOK=y

CONFIG_RTC_DRV_CMOS=y

CONFIG_X86_ACPI_CPUFREQ=m

dnl The default is to support those old ISA boxes.
dnl A target might get rid of it.
dnl
CONFIG_ISA=y
CONFIG_ISAPNP=y
CONFIG_PNPBIOS=y
CONFIG_PNP=y

CONFIG_PATA_LEGACY=m

dnl The default x86 frame-buffer fallback
dnl
CONFIG_FB_VESA=y
CONFIG_VGA_SWITCHEROO=y
CONFIG_FB_GEODE=y

dnl does often corrupt the FB
# CONFIG_FB_NVIDIA is not set
