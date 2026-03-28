# --- T2-COPYRIGHT-BEGIN ---
# t2/target/test/build.sh
# Copyright (C) 2006 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

# filter to avoid some non-runtime stuff (static libs, man-pages, ...)
rescue_rootfs_filter ()
{
	sed -i '/\.a$/d
	        /\.la$/d
		/\/pkgconfig\//d
	        /\/include\//d
	        /\/locale\//d
	        /\/pkgconfig\//d
	        /\/info\//d
	        /\/man\//d
	        /\/doc\//d
	        /\/i18n\//d
		/var\/adm/d
	        /usr\/src\//d' "$1"
	cut -d ' ' -f 2- $build_root/var/adm/flists/gcc |
	grep '/lib\(gcc\|std\).*.so' >> "$1"
}
filter_hook=rescue_rootfs_filter

# do not include some devel packages
var_append pkg_filter ' ' 'binutils gcc dietlibc autoconf automake libtool'
var_append pkg_filter ' ' 'flex bison texinfo ccache distcc m4 make cmake'
var_append pkg_filter ' ' 'scons python perl perl-xml-parser intltool'

. target/generic/build.sh

# now this is a hack - and x86 specific anyway :-(
if [ "$SDECFG_TARGET_RESCUE_STYLE" = "livecd" ]; then
  if [[ $arch = x86* ]]; then
	case "$SDECFG_X86_CD_LOADER" in
	grub)
		sed -i 's/kernel.*/& vga=0x317/' $isofsdir/boot/grub/menu.lst ;;
	isolinux)
		sed -i 's/APPEND.*/& vga=0x317/' $isofsdir/boot/isolinux/isolinux.cfg ;;
	*)
		echo "Adapt target/rescue/build.sh for unknown boot loader: $SDECFG_X86_CD_LOADER" ;;
	esac
  fi
fi
