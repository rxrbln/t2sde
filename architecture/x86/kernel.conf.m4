define(`INTEL', `Intel X86 PCs')dnl
		
dnl CPU configuration
dnl

define(`config', `CONFIG_M$1=y')dnl
ifelse( `i386',         _ARCH, config(386),
	`i486',         _ARCH, config(486),
	`pentium',      _ARCH, config(586),
	`pentium-mmx',  _ARCH, config(586MMX),
	`pentiumpro',   _ARCH, config(686),
	`pentium2',     _ARCH, config(686),
	`pentium3',     _ARCH, config(PENTIUMIII),
	`pentium4',     _ARCH, config(PENTIUM4),
	`k6',           _ARCH, config(K6),
	`k6-2',         _ARCH, config(K6),
	`k6-3',         _ARCH, config(K6),
	`athlon',       _ARCH, config(K7),
	`athlon-tbird', _ARCH, config(K7),
	`athlon4',      _ARCH, config(K7),
	`athlon-xp',    _ARCH, config(K7),
	`athlon-mp',    _ARCH, config(K7), config(386))
undefine(`config')dnl

dnl Memory Type Range Register support
dnl (improvements in graphic speed ...)
dnl
CONFIG_MTRR=y
include(`kernel-common.conf')
include(`kernel-scsi.conf')
include(`kernel-net.conf')
include(`kernel-fs.conf')

