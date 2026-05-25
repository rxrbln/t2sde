dnl --- T2-COPYRIGHT-BEGIN ---
dnl t2/architecture/hexagon/linux.conf.m4
dnl Copyright (C) 2004 - 2026 The T2 SDE Project
dnl SPDX-License-Identifier: GPL-2.0
dnl --- T2-COPYRIGHT-END ---

define(`HEXAGON', 'Hexagon')dnl

dnl Hexagon
dnl

CONFIG_PCI=y
CONFIG_NET=y
CONFIG_UNIX=y
CONFIG_INET=y
CONFIG_VIRTIO_BLK=y
CONFIG_NETDEVICES=y
CONFIG_VIRTIO_NET=y
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_SERIAL_OF_PLATFORM=y
CONFIG_VIRT_DRIVERS=y
CONFIG_VIRTIO_MMIO=y
CONFIG_EXT4_FS=y

include(`linux-common.conf.m4')
include(`linux-block.conf.m4')
include(`linux-net.conf.m4')
include(`linux-fs.conf.m4')
