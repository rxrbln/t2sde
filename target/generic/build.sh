# --- T2-COPYRIGHT-BEGIN ---
# t2/target/generic/build.sh
# Copyright (C) 2004 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

# This is the shortest possible target build.sh script. Some targets will
# add code after calling pkgloop() or modify pkgloop's behavior by defining
# a new pkgloop_action() function.

pkgloop

echo_header "Finishing build."

rm -f $build_toolchain/isofs*.txt 2> /dev/null

if [ "$SDECFG_PKGFILE_TYPE" != "none" ]; then
	echo_status "Creating package database ..."
	admdir="build/${SDECFG_ID}/var/adm"
	create_package_db $admdir $build_toolchain/pkgs \
	                  $build_toolchain/pkgs/packages.db
fi

if [ "$SDECFG_IMAGE" -a -e target/share/$SDECFG_IMAGE/build.sh ]; then
	echo_status "Creating output image ..."
	. target/share/$SDECFG_IMAGE/build.sh
fi

echo_status "Creating isofs.txt file .."
(
  if [ "$SDECFG_PKGFILE_TYPE" != "none" ]; then
    cat <<-EOT
	DISK1	$admdir/cache/		${SDECFG_SHORTID}/info/cache/
	DISK1	$admdir/dependencies/	${SDECFG_SHORTID}/info/dependencies/
	DISK1	$admdir/descs/		${SDECFG_SHORTID}/info/descs/
	DISK1	$admdir/flists/		${SDECFG_SHORTID}/info/flists/
	DISK1	$admdir/md5sums/	${SDECFG_SHORTID}/info/md5sums/
	DISK1	$admdir/packages/	${SDECFG_SHORTID}/info/packages/
	EVERY	$build_toolchain/pkgs/packages.db	${SDECFG_SHORTID}/pkgs/packages.db
	SPLIT	$build_toolchain/pkgs/	${SDECFG_SHORTID}/pkgs/
EOT
  fi
  cat $build_toolchain/isofs_*.txt 2>/dev/null
) > $build_toolchain/isofs.txt
