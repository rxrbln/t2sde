#!/bin/bash

boot_title="Archivista Box - $build_date"
. $base/target/share/$SDECFG_IMAGE/build_initrd.sh

# sort the kernel images according our wishes
awk -f $base/target/archivista/rootfs/home/archivista/sort-kernel.awk < \
       $isofsdir/boot/grub/menu.lst > $isofsdir/boot/grub/menu.lst.new
mv -f $isofsdir/boot/grub/menu.lst{.new,}
