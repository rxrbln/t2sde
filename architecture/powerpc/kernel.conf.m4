define(`PPC', 'PowerPC')dnl

dnl System type (default=iMac)
dnl
CONFIG_PPC=y
CONFIG_6xx=y
# CONFIG_4xx is not set
# CONFIG_PPC64 is not set
# CONFIG_82xx is not set
# CONFIG_8xx is not set
CONFIG_PMAC=y
# CONFIG_PREP is not set
# CONFIG_CHRP is not set
# CONFIG_ALL_PPC is not set
# CONFIG_GEMINI is not set
# CONFIG_APUS is not set
# CONFIG_SMP is not set
# CONFIG_ALTIVEC is not set
CONFIG_MACH_SPECIFIC=y

include(`kernel-common.conf')
include(`kernel-fs.conf')

dnl macs need an FB
CONFIG_FB_RIVA=y
CONFIG_FB_MATROX=m
CONFIG_FB_ATY=y
CONFIG_FB_RADEON=y

dnl power management
CONFIG_PMAC_PBOOK=y
CONFIG_PMAC_BACKLIGHT=y
CONFIG_MAC_FLOPPY=y

dnl usefull stuff
# CONFIG_MAC_ADBKEYCODES is not set
CONFIG_PMAC_APM_EMU=yes

dnl currently broken on powerpc
# CONFIG_SCx200_I2C is not set
# CONFIG_SCx200_ACB is not set

