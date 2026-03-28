# --- T2-COPYRIGHT-BEGIN ---
# t2/target/wrt2/build.sh
# Copyright (C) 2004 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

pkgloop

imagelocation="$build_toolchain/rootfs"
. $base/target/$target/build_image.sh

echo_status "Done!"

