define(`ALPHA', `Alpha AXP')dnl

CONFIG_ALPHA_GENERIC=y
# CONFIG_BINFMT_EM86 is not set


include(`kernel-common.conf')
include(`kernel-scsi.conf')
CONFIG_BLK_DEV_CY82C693=y

include(`kernel-net.conf')
include(`kernel-fs.conf')
