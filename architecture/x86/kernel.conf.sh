
{
	cat <<- 'EOT'
		define(`INTEL', `Intel X86 PCs')dnl
		
		dnl CPU configuration
		dnl
	EOT

	linux_arch=386
	for x in "i386		386"		\
		 "i486		486"		\
		 "via-c3	MCYRIXIII"	\
		 "via-c3-2	MVIAC3_2"	\
		 "pentium	586"		\
		 "pentium-mmx	586MMX"		\
		 "pentiumpro	686"		\
		 "pentium2	PENTIUMII"	\
		 "pentium3	PENTIUMIII"	\
		 "pentium4	PENTIUM4"	\
		 "k6		K6"		\
		 "k6-2		K6"		\
		 "k6-3		K6"		\
		 "athlon	K7"		\
		 "athlon-tbird	K7"		\
		 "athlon4	K7"		\
		 "athlon-xp	K7"		\
		 "athlon-mp	K7"
	do
		set $x
		[ "$1" = "$ROCKCFG_X86_OPT" ] && linux_arch=$2
	done

	# echo `grep -A 20 'Processor family' \
	#	/usr/src/linux/arch/i386/config.in | expand | \
	#	cut -c 57- | cut -f1 -d' ' | tr -d '"'`
	#
	for x in 386 486 586 586TSC 586MMX 686 PENTIUMIII PENTIUM4 \
	         K6 K7 K8 ELAN CRUSOE WINCHIPC6 WINCHIP2 WINCHIP3D \
	         CYRIXIII VIAC3_2
	do
		if [ "$linux_arch" != "$x" ]
		then echo "# CONFIG_M$x is not set"
		else echo "CONFIG_M$x=y" ; fi
	done

	echo
	cat <<- 'EOT'
		dnl Memory Type Range Register support
		dnl (improvements in graphic speed ...)
		dnl
		CONFIG_MTRR=y

		dnl Some AGP support not enabled by default
		dnl
		CONFIG_AGP_AMD_8151=y
		CONFIG_AGP_SWORKS is not set

		dnl PC Speaker for 2.5/6 kernel
		CONFIG_INPUT_PCSPKR=y

		dnl Other useful stuff
		dnl
		CONFIG_RTC=y

		include(`kernel-common.conf')
		include(`kernel-scsi.conf')
		include(`kernel-net.conf')
		include(`kernel-fs.conf')
	EOT
} | m4 -I $base/architecture/$arch -I $base/architecture/share

