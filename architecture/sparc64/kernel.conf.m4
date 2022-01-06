define(`SPARC', 'SPARC')dnl

dnl does at least not work for sun4 - and should not be really needed
dnl on 32bit SPARCs (it is also not a default for our x86 default config)
# CONFIG_HIGHMEM is not set

# CONFIG_SUN4 is not set

CONFIG_FB=y
CONFIG_FB_SBUS=y
CONFIG_FB_CGSIX=y
CONFIG_FB_BWTWO=y
CONFIG_FB_CGTHREE=y
CONFIG_FB_TCX=y
CONFIG_FB_CGFOURTEEN=y
CONFIG_FB_P9100=y
CONFIG_FB_LEO=y

CONFIG_FB_ATY=y

# CONFIG_FB_RIVA is not set
# CONFIG_FB_RADEON is not set

CONFIG_FONT_8x16=y
CONFIG_FONT_SUN8x16=y
CONFIG_FONT_SUN12x22=y

include(`kernel-common.conf.m4')
include(`kernel-scsi.conf.m4')
include(`kernel-net.conf.m4')
include(`kernel-fs.conf.m4')

dnl LSI Logic / Symbios Logic (formerly NCR) 53c810 (rev 01)
dnl does not work reliable with MMIO on my Ultra SPARC 5
dnl Rene Rebe <rene@rocklinux.org>
# CONFIG_SCSI_SYM53C8XX_IOMAPPED is not set

