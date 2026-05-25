# --- T2-COPYRIGHT-BEGIN ---
# t2/target/share/live/build.sh
# Copyright (C) 2004 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---
#
#Description: Live

isofsdir="$build_toolchain/isofs"	# for the ISO9660 content
imagelocation="$build_toolchain/rootfs"	# where the roofs is prepared and sq.

# Wipe existing content, otherwise updated kernel or changed boot loader
# accumulate.
rm -rf $isofsdir; mkdir -p $isofsdir

# Create the live initrd's first.
. $base/target/share/live/build_initrd.sh
. $base/target/share/live/build_image.sh

echo_status "Done!"
