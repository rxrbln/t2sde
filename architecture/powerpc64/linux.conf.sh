# --- T2-COPYRIGHT-BEGIN ---
# t2/architecture/powerpc64/linux.conf.sh
# Copyright (C) 2013 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

{
	linux_arch=GENERIC_CPU
	for x in "generic	GENERIC_CPU"	\
		 "power3	POWER3_CPU"	\
		 "power4	POWER4_CPU"	\
		 "cell		CELL_CPU"	\
		 "G5		POWER4_CPU"	\
		 "power5	POWER5_CPU"	\
		 "power6	POWER6_CPU"	\
		 "power7	POWER7_CPU"	\
		 "power8	POWER8_CPU"	\
		 "power9	POWER9_CPU"	\
		 "power10	POWER10_CPU"
	do
		set $x
		[[ "$SDECFG_POWERPC64_OPT" = $1 ]] && linux_arch=$2
	done

	for x in GENERIC_CPU POWER3_CPU POWER4_CPU CELL_CPU \
		 POWER5_CPU POWER6_CPU POWER7_CPU POWER8_CPU
	do
		if [ "$linux_arch" != "$x" ]
		then echo "# CONFIG_$x is not set"
		else echo "CONFIG_$x=y" ; fi
	done

	cat <<- 'EOT'
 		include(`linux.conf.m4')
	EOT

	if [ "$SDECFG_POWERPC64_ENDIANESS" = "le" ]; then
		echo "CONFIG_CPU_LITTLE_ENDIAN=y"
		echo "CONFIG_NR_CPUS=256"
		echo "CONFIG_PPC_PSERIES=y"
		echo "CONFIG_HZ_1000=y"
	else
		echo "CONFIG_CPU_BIG_ENDIAN=y"
		echo "CONFIG_NR_CPUS=8"
		echo "# CONFIG_PPC_PSERIES is not"
	fi
} | m4 -I $base/architecture/$arch -I $base/architecture/powerpc -I $base/architecture/share
