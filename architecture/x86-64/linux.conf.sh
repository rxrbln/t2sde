# --- T2-COPYRIGHT-BEGIN ---
# t2/architecture/x86-64/linux.conf.sh
# Copyright (C) 2004 - 2025 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

{
	cat <<- 'EOT'
		define(`INTEL', `Intel X86 PCs')dnl

		CONFIG_64BIT=y
	EOT

	echo
	cat <<- 'EOT'
		dnl Other useful stuff
		dnl
		include(`linux-common.conf.m4')
		include(`linux-block.conf.m4')
		include(`linux-net.conf.m4')
		include(`linux-fs.conf.m4')
		include(`linux-x86.conf.m4')

		CONFIG_NR_CPUS=512
		CONFIG_HZ_1000=y

		CONFIG_TRANSPARENT_HUGEPAGE=y
		CONFIG_HUGETLBFS=y

		CONFIG_IA32_EMULATION=y
		CONFIG_X86_X32=y
		CONFIG_X86_X32_ABI=y
		CONFIG_X86_POSTED_MSI=y
		CONFIG_PREEMPT_LAZY=y

		CONFIG_NUMA=y
		CONFIG_NUMA_BALANCING=y

		CONFIG_AMD_IOMMU=y
		CONFIG_INTEL_IOMMU=y
		CONFIG_INTEL_IOMMU_SVM=y
		CONFIG_HYPERV_IOMMU_SVM=y
		CONFIG_XEN_VIRTIO=y

		dnl Support for latest low level clocks, gpio, and i2c glue
		dnl
		CONFIG_X86_AMD_PSTATE=y
		CONFIG_X86_AMD_PLATFORM_DEVICE=y
		CONFIG_X86_INTEL_LPSS=m
		CONFIG_I2C_DESIGNWARE_BAYTRAIL=y
		CONFIG_I2C_DESIGNWARE_AMDPSP=y
		CONFIG_I2C_DESIGNWARE_SLAVE=y
		CONFIG_PMIC_OPREGION=y
		CONFIG_INTEL_SOC_PMIC=y
		CONFIG_PINCTRL_AMD=y
	EOT
} | m4 -I $base/architecture/$arch -I $base/architecture/x86 -I $base/architecture/share
