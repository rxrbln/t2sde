define(`ALPHA', `Alpha AXP')dnl

CONFIG_ALPHA_GENERIC=y
# CONFIG_BINFMT_EM86 is not set

include(`kernel-common.conf')
include(`kernel-scsi.conf')
include(`kernel-net.conf')
include(`kernel-fs.conf')
