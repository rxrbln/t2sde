define(`ALPHA', `Alpha AXP')dnl

CONFIG_ALPHA_GENERIC=y
# CONFIG_BINFMT_EM86 is not set


include(`kernel-common.conf.m4')
include(`kernel-scsi.conf.m4')
CONFIG_BLK_DEV_CY82C693=y

include(`kernel-net.conf.m4')
include(`kernel-fs.conf.m4')
