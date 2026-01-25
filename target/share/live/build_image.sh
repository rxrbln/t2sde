#!/bin/bash
# --- T2-COPYRIGHT-BEGIN ---
# t2/target/share/live/build_image.sh
# Copyright (C) 2004 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

. $base/misc/target/functions.in

set -e

mkdir -p $imagelocation; cd $imagelocation
# just in case it is still there from the last run
[ "$SDECFG_CROSSBUILD" != 1 ] && umount ./proc ./dev 2>/dev/null || true

echo "Creating root file-system file lists ..."
f=" $pkg_filter "
for pkg in `grep '^X ' $base/config/$config/packages | cut -d ' ' -f 5`; do
	# include the package?
	if [ "${f/ $pkg /}" == "$f" ]; then
		cut -d ' ' -f 2 $build_root/var/adm/flists/$pkg || true
	fi
done | sort -u > ../files-wanted
unset f
[ "$filter_hook" ] && "$filter_hook" ../files-wanted

# for rsync with --delete we can not use file lists, since rsync does not
# delete in that mode - instead we need to generate a negative list

find $build_root -mount -wholename $build_root/TOOLCHAIN -prune -o -type f -printf '%P\n' |
	sort -u > ../files-all
# the difference
diff -u ../files-all ../files-wanted |
sed -n -e '/var\/adm\/olist/d' -e '/var\/adm\/logs/d' \
       -e '/var\/adm\/dep-debug/d' -e '/var\/adm\/cache/d' -e 's/^-\([^-]\)/\1/p' > ../files-exclude
echo "TOOLCHAIN
proc/*
dev/*
var/adm/olist
var/adm/logs
var/adm/dep-debug" >> ../files-exclude

echo "Syncing root file-system (this may take some time) ..."
[ -e $imagelocation/bin ] && v="-v" || v=""
rsync -artH $v --devices --specials --delete --delete-excluded \
     --exclude-from ../files-exclude $build_root/ $imagelocation/
rm ../files-{wanted,all,exclude}

echo "Overlaying root file-system with target defined files ..."
[ -e $base/target/share/live/rootfs ] &&
	copy_and_parse_from_source $base/target/share/live/rootfs $imagelocation
[ -e $base/target/$target/rootfs ] &&
	copy_and_parse_from_source $base/target/$target/rootfs $imagelocation

[ "$inject_hook" ] && "$inject_hook"

if [ "$SDECFG_CROSSBUILD" != 1 ]; then
    echo "Running ldconfig and other postinstall scripts ..."
    mount /dev dev --bind
    mount /proc proc --bind
    for x in sbin/ldconfig etc/postinstall.d/*; do
	case $x in
		*) chroot . /bin/bash -c ". /etc/profile; /$x" && true ;;
	esac
    done
    umount dev proc
fi

echo "Squashing root file-system ..."
mksquashfs . $isofsdir/live.squash -noappend -comp zstd -Xcompression-level 15 \
  -b 1M -processors "$(nproc)" # -no-progress -no-exports
du -sh $isofsdir/live.squash
