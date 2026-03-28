# --- T2-COPYRIGHT-BEGIN ---
# t2/target/share/pkgdist/build.sh
# Copyright (C) 2006 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---
#
#Description: Distribute binary packages to (remote) location

if [ "$SDECFG_TARGET_PKGDIST_LOCATION" ]; then
	echo_header "Package distribution"

	case "$SDECFG_TARGET_PKGDIST_LOCATION" in
	http:*|ftp:*)
		echo_warning "Remote package distribution not supported yet"
		;;
	*)
		echo_status "Copying package files to $SDECFG_TARGET_PKGDIST_LOCATION..."
		mkdir -p $SDECFG_TARGET_PKGDIST_LOCATION
		cp -a $base/build/$SDECFG_ID/TOOLCHAIN/pkgs/* $SDECFG_TARGET_PKGDIST_LOCATION/
		;;
	esac
fi

exit

