echo_header "Creating image directory..."

#FIXME grub
mkdir -p $isofsdir/{boot/isolinux,rootfs,doc,tmp}

pushd $isofsdir >/dev/null
    
    echo_status "Copying files..."

    # copy bootloader files
    #FIXME not only cd, compare ROCKCFG_TARGET_DISTCD_BOOTTYPE=cd
    cp $build_root/usr/lib/syslinux/isolinux.bin boot/isolinux/
    #FIXME grub: cp tmp/boot/grub/* boot/grub/

    # prepare bootloader config
    #FIXME default entry is first of $initrd_images...
    cat <<EOF > boot/isolinux/isolinux.cfg
#DEFAULT 
EOF
# FIXME grub:
#    cat <<EOF > boot/grub/menu.lst
#timeout 100
#
##color cyan/blue white/blue
##splashimage=/boot/grub/splash.xpm.gz

    # kernel
    for each in $initrd_images; do
	[ -e $build_root/boot/vmlinuz_$each ] && cp $build_root/boot/vmlinuz_$each boot/
    done

    # initrd-$kver.img ...
    for each in $initrd_images; do
	echo_status "Creating initrd-$each.img..."
	if [ "$USE_SQUASHFS" = "y" ]; then
	    : FIXME
	elif [ "$USE_CRAMFS" = "y" ]; then
	    mkcramfs $initrddir-$each boot/initrd-$each.img
	else
	    echo_error "Filesystem cramfs/squashfs not supported by kernel..."
	    exit -1
	fi

	ramdisk_size="`ls -lak boot/initrd-$each.img | awk '{ print $5; }'`"
	#MAYBE ceil to multiple of 4096 or so?

	echo_status "Creating menu..."
	cat <<EOF >> boot/isolinux/isolinux.cfg
LABEL $each
    KERNEL /boot/vmlinuz_$each
    APPEND initrd=/boot/initrd-$each.img rw ramdisk_size=$ramdisk_size root=/dev/ram0 init=/linuxrc
EOF
# FIXME grub:
#title DistCC Live-CD
#(cd)/boot/vmlinuz ro ramdisk_size=8192 root=/dev/ram0 initrd init=/linuxrc
#(cd)/boot/initrd.img
#EOF
    done

#FIXME
#cat > ../isofs_arch.txt <<- EOT
#		BOOT	-b isolinux/isolinux.bin -c isolinux/boot.catalog
#		BOOTx	-no-emul-boot -boot-load-size 4 -boot-info-table
#		DISK1	build/${ROCKCFG_ID}/TOOLCHAIN/bootdisk/isolinux/ isolinux/
#EOT

popd >/dev/null
echo_status Done.
