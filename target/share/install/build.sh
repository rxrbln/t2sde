# --- T2-COPYRIGHT-BEGIN ---
# t2/target/share/install/build.sh
# Copyright (C) 2004 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---
#
#Description: Install ISO

isofsdir="$build_toolchain/isofs"      # for the ISO9660 content

# Wipe existing content, otherwise updated kernel or changed boot loader
# accumulate.
rm -rf $isofsdir; mkdir -p $isofsdir

# Create the 1st stage loader initrd's first.
. $base/target/share/install/build_initrd.sh
. $base/target/share/install/build_stage2.sh
