#!/bin/bash
# --- T2-COPYRIGHT-BEGIN ---
# t2/target/embedded/build_image.sh
# Copyright (C) 2004 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

. $base/misc/target/functions.in

set -e

echo "Preparing root filesystem image from build result ..."

rm -rf $imagelocation{,.squashfs}
mkdir -p $imagelocation ; cd $imagelocation

find $build_root -printf "%P\n" | sed '

# stuff we never need

/^TOOLCHAIN/	d;
/^var\/adm/	d;

/\/include/	d;
/\/src/		d;
/\.a$/		d;
/\.o$/		d;
/\.old$/	d;

/\/games/	d;
/\/local/	d;
/^boot/		d;

# # stuff that would be nice - but is huge and only documentation
/\/man/		d;
/\/doc/		d;

# /etc noise
/^etc\/stone.d/	d;
/^etc\/cron.d/	d;
/^etc\/init.d/	d;

/^etc\/skel/	d;
/^etc\/opt/	d;
/^etc\/conf/	d;
/^etc\/rc.d/	d;

/^opt/		d;

/^\/man\//	d;

/terminfo\/a\/ansi$/	{ p; d; }
/terminfo\/l\/linux$/	{ p; d; }
/terminfo\/x\/xterm$/	{ p; d; }
/terminfo\/n\/nxterm$/	{ p; d; }
/terminfo\/x\/xterm-color$/	{ p; d; }
/terminfo\/x\/xterm-8bit$/	{ p; d; }
/terminfo\/x\/screen$/	{ p; d; }
/terminfo\/v\/vt100$/	{ p; d; }
/terminfo\/v\/vt200$/	{ p; d; }
/terminfo\/v\/vt220$/	{ p; d; }
/terminfo/	d;

' > tar.input

copy_with_list_from_file $build_root . $PWD/tar.input
rm tar.input

echo "Preparing root filesystem image from target defined files ..."
rm -f sbin/init ; ln -s minit sbin/init
copy_from_source $base/target/$target/rootfs .

echo "Creating links for identical files ..."
link_identical_files

echo "Creating root filesystem image (squashfs) ..."

mksquashfs $imagelocation{,.squashfs} > /dev/null

du -sh $imagelocation{,.squashfs}

echo "The image is located at $imagelocation.squasfs."

