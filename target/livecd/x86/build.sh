
syslinux_ver="`sed -n 's,.*syslinux-\(.*\).tar.*,\1,p' \
               $base/target/livecd/download.txt`"

cd $disksdir

echo_header "Creating isolinux setup:"
#
echo_status "Extracting isolinux boot loader."
mkdir -p isolinux
tar --use-compress-program=bzip2 \
    -xf $base/download/livecd/syslinux-$syslinux_ver.tar.bz2 \
    syslinux-$syslinux_ver/isolinux.bin -O > isolinux/isolinux.bin
#
echo_status "Creating isolinux config file."
cp $base/target/$target/x86/isolinux.cfg isolinux/
cp $base/target/$target/x86/help?.txt isolinux/
#
echo_status "Copy images to isolinux directory."
cp boot/memtest86.bin isolinux/memtest86
cp initrd.gz boot/vmlinuz isolinux/
#
cat > ../isofs_arch.txt <<- EOT
	BOOT	-b isolinux/isolinux.bin -c isolinux/boot.catalog
	BOOTx	-no-emul-boot -boot-load-size 4 -boot-info-table
	DISK1	build/${ROCKCFG_ID}/ROCK/livecd/isolinux/ isolinux/
EOT

