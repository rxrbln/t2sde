dnl --- T2-COPYRIGHT-BEGIN ---
dnl t2/architecture/share/linux-net.conf.m4
dnl Copyright (C) 2004 - 2025 The T2 SDE Project
dnl SPDX-License-Identifier: GPL-2.0
dnl --- T2-COPYRIGHT-END ---

dnl the basic sections
dnl
CONFIG_NET=y
CONFIG_PACKET=y
CONFIG_PACKET_MMAP=y
CONFIG_UNIX=y
CONFIG_INET=y
CONFIG_NETLINK=y
CONFIG_RTNETLINK=y

CONFIG_XDP_SOCKETS=y

CONFIG_TCP_CONG_ADVANCED=y

CONFIG_BRIDGE_VLAN_FILTERING=y

CONFIG_NETDEVICES=y
CONFIG_NET_ETHERNET=y

CONFIG_LED_TRIGGER_PHY=y

CONFIG_NET_ISA=y
CONFIG_NET_EISA=y
CONFIG_NET_PCI=y
CONFIG_NET_POCKET=y

dnl Enable some vendor sections
dnl
CONFIG_NET_VENDOR_3COM=y
CONFIG_NET_VENDOR_SMC=y
CONFIG_NET_VENDOR_RACAL=y

dnl make sure those are modular (built-in by default)
dnl
CONFIG_8139TOO=m
CONFIG_8139TOO_TUNE_TWISTER=y
CONFIG_8139TOO_8129=y
CONFIG_FORCEDETH=m
CONFIG_E1000=m
CONFIG_MLX5_CORE_EN=y

dnl Enable some categories so drivers are enabled as modules
dnl
CONFIG_NET_RADIO=y
CONFIG_NET_PCMCIA=y
CONFIG_NET_TULIP=y

dnl Misc network device support
dnl
CONFIG_PPP=m
CONFIG_PPP_FILTER=y

dnl Enable IP autoconfiguration
dnl
# CONFIG_IP_PNP is not set
dnl CONFIG_IP_PNP_BOOTP=y
dnl CONFIG_IP_PNP_DHCP=y

dnl Enable some nice networking features
dnl
CONFIG_IP_ADVANCED_ROUTER=y
CONFIG_IP_MULTIPLE_TABLES=y
CONFIG_IP_MULTICAST=y
CONFIG_FILTER=y

dnl Enable QoS and IP-Tables (drivers themself are modules)
dnl 
CONFIG_NET_SCHED=y
CONFIG_NETFILTER=y
CONFIG_NETFILTER_FAMILY_ARP=y
CONFIG_NET_QOS=y
CONFIG_NET_CLS=y

dnl Disable dangerous packet generator
dnl
# CONFIG_NET_PKTGEN is not set

dnl Disable PTP classifier that JITs code on each boot oopsing on ps3
# CONFIG_PTP_1588_CLOCK is not set

dnl Important BT settings, RFCOM_TTY that is
dnl
CONFIG_BT=y
CONFIG_BT_L2CAP=m
CONFIG_BT_RFCOMM=m
CONFIG_BT_RFCOMM_TTY=y

dnl Enable fibre channel support
CONFIG_NET_FC=y

dnl Wireless Fidelity
CONFIG_WLAN_PRE80211=y
CONFIG_WLAN_80211=y

dnl some more vendor options
CONFIG_BRCMFMAC_USB=y
CONFIG_BRCMFMAC_PCIE=y

dnl rare / obsolete stuff
# CONFIG_ISDN is not set
# CONFIG_WIMAX is not set
# CONFIG_DECNET is not set

dnl Enable NF-TABLES support
dnl
CONFIG_NF_TABLES_INET=y
CONFIG_NF_TABLES_NETDEV=y
CONFIG_NF_NAT_REDIRECT=y
CONFIG_NF_TABLES_IPV4=y
CONFIG_NF_TABLES_ARP=y
CONFIG_NF_TABLES_IPV6=y

dnl this driver enabled OF_OVERLAY for all $arch
# CONFIG_MCHP_LAN966X_PCI is not set
