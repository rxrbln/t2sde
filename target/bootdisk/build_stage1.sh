
echo_header "Creating initrd data:"
rm -rf $disksdir/initrd
mkdir -p $disksdir/initrd/{dev,proc,tmp,scsi,net,bin}
cd $disksdir/initrd; ln -s bin sbin; ln -s . usr
#
echo_status "Create linuxrc binary."
diet $CC $base/target/$target/linuxrc.c -Wall \
	-DSTAGE_2_BIG_IMAGE="\"${ROCKCFG_SHORTID}/2nd_stage.tar.gz\"" \
	-DSTAGE_2_SMALL_IMAGE="\"${ROCKCFG_SHORTID}/2nd_stage_small.tar.gz\"" \
	-o linuxrc > $disksdir/tmp 2>&1
# Only print this output if it's not the usual dietlibc junk
x="$( sed 's,^[^:]*: ,~~: ,' < $disksdir/tmp | md5sum | cut -f1 -d' ' )"
if [ "$x" != "0ede96ab34b5572403579dfb48ebe10c" ] ; then
	cat $disksdir/tmp ; echo "[ $x ]"
fi ; rm -f $disksdir/tmp
#
echo_status "Copy various helper applications."
cp ../2nd_stage/bin/{tar,gzip} bin/
cp ../2nd_stage/sbin/{ip,hwscan} bin/
cp ../2nd_stage/usr/bin/{wget,gawk} bin/
for x in modprobe.static modprobe.static.old \
         insmod.static insmod.static.old
do
	if [ -f ../2nd_stage/sbin/${x/.static/} ]; then
		rm -f bin/${x/.static/}
		cp -a ../2nd_stage/sbin/${x/.static/} bin/
	fi
	if [ -f ../2nd_stage/sbin/$x ]; then
		rm -f bin/$x bin/${x/.static/}
		cp -a ../2nd_stage/sbin/$x bin/
		ln -sf $x bin/${x/.static/}
	fi
done
#
echo_status "Copy scsi and network kernel modules."
for x in ../2nd_stage/lib/modules/*/kernel/drivers/{scsi,net}/*.o; do
	mkdir -p $( dirname ${x#../2nd_stage/} )
	cp $x ${x#../2nd_stage/}
	strip --strip-debug --strip-unneeded ${x#../2nd_stage/}
done
cp ../2nd_stage/lib/modules/*/modules.dep       lib/modules/[0-9]*/
cp ../2nd_stage/lib/modules/*/modules.pcimap    lib/modules/[0-9]*/
cp ../2nd_stage/lib/modules/*/modules.isapnpmap lib/modules/[0-9]*/
for x in lib/modules/*/kernel/drivers/{scsi,net}; do
	ln -s ${x#lib/modules/} lib/modules/
done
rm -f lib/modules/[0-9]*/kernel/drivers/scsi/{st,scsi_debug}.o
rm -f lib/modules/[0-9]*/kernel/drivers/net/{dummy,ppp*}.o
#
if [ "$ROCK_DEBUG_BOOTDISK_USEKISS" = 1 ]; then
	echo_status "Using kiss shell for debugging initrd image."
	cp /bin/kiss bin/; mv linuxrc bin/; ln -s bin/kiss linuxrc
	rm -f lib/modules/[0-9]*/kernel/drivers/net/{dgrx,acenic}.o
	rm -f lib/modules/[0-9]*/kernel/drivers/scsi/{advansys,qla1280}.o
fi
cd ..

echo_header "Creating initrd filesystem image: "
#
echo_status "Creating temporary files."
tmpdir=initrd_$$.dir; mkdir -p $disksdir/$tmpdir; cd $disksdir
dd if=/dev/zero of=initrd.img bs=1024 count=4096 &> /dev/null
tmpdev=""
for x in /dev/loop/* ; do
        if losetup $x initrd.img 2> /dev/null ; then
                tmpdev=$x ; break
        fi
done
if [ -z "$tmpdev" ] ; then
        echo_error "No free loopback device found!"
        rm -f $tmpfile ; rmdir $tmpdir; exit 1
fi
echo_status "Using loopback device $tmpdev."
#
echo_status "Writing initrd image file."
mke2fs -q $tmpdev &> /dev/null
mount -t ext2 $tmpdev $tmpdir
cp -a initrd/* $tmpdir
umount $tmpdir
#
echo_status "Removing temporary files."
losetup -d $tmpdev
rm -rf $tmpdir
