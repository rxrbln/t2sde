
dnl Enable Quota Support
dnl
CONFIG_QUOTA=y

dnl FAT is still very importand
dnl
CONFIG_FAT_FS=y
CONFIG_MSDOS_FS=y
# CONFIG_UMSDOS_FS is not set
CONFIG_VFAT_FS=y

dnl ISO9660 support (including JOLIET and ZISOFS compression)
dnl
CONFIG_ISO9660_FS=y
CONFIG_JOLIET=y
CONFIG_ZISOFS=y

dnl Enable IBM JFS
dnl
CONFIG_JFS_FS=y
CONFIG_JFS_POSIX_ACL=y
# CONFIG_JFS_DEBUG is not set
# CONFIG_JFS_STATISTICS is not set

dnl Enable SGI XFS
dnl
CONFIG_XFS_FS=y
# CONFIG_XFS_RT is not set
# CONFIG_XFS_QUOTA is not set
CONFIG_XFS_POSIX_ACL=y

dnl DevFS and Proc
dnl in the past we had DEVPTS disabled since it is done in DevFS
dnl unfortunately it got removed in 2.5 due to the code duplication.
dnl So now even with devfs devpts must be enabled and used.
dnl
CONFIG_DEVFS_FS=y
CONFIG_DEVFS_MOUNT=y
# CONFIG_DEVFS_DEBUG is not set
CONFIG_DEVPTS_FS=y
CONFIG_PROC_FS=y

dnl Enable ext2fs and ext3fs
dnl
CONFIG_EXT2_FS=y
CONFIG_EXT2_FS_XATTR=y
CONFIG_EXT2_FS_POSIX_ACL=y
CONFIG_EXT2_FS_SUIDDIR=y
CONFIG_EXT3_FS=y
CONFIG_EXT3_FS_XATTR=y
CONFIG_EXT3_FS_POSIX_ACL=y
CONFIG_EXT3_FS_SUIDDIR=y

dnl Reiser Filesystem
dnl
CONFIG_REISERFS_FS=y
# CONFIG_REISERFS_CHECK is not set
# CONFIG_REISERFS_PROC_INFO is not set
CONFIG_REISERFS_FS_SUIDDIR=y

dnl Network FS settings
dnl Version 3 has several advantages ...
dnl
CONFIG_NFS_FS=y
CONFIG_NFS_V3=y
CONFIG_NFSD_V3=y

dnl ROMFS, RAMFS, CRAMFS and TMPFS (for initrd, install and /tmp)
dnl
CONFIG_ROMFS_FS=y
CONFIG_RAMFS=y
CONFIG_CRAMFS=y
CONFIG_TMPFS=y

