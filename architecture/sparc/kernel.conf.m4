define(`SPARC', 'SPARC')dnl

CONFIG_FB=y
CONFIG_FB_SBUS=y
CONFIG_FB_CGSIX=y
CONFIG_FB_BWTWO=y
CONFIG_FB_CGTHREE-y
CONFIG_FB_TCX=y
CONFIG_FB_CGFOURTEEN=y
CONFIG_FB_P9100=y
CONFIG_FB_LEO=y

include(`kernel-common.conf')
include(`kernel-scsi.conf')
include(`kernel-net.conf')
include(`kernel-fs.conf')

