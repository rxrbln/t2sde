
use_yaboot=1

cd $disksdir

echo_header "Creating cleaning boot directory:"
rm -rfv boot/*-rock boot/System.map boot/kconfig*

if [ $use_yaboot -eq 1 ]
then
	echo_header "Creating yaboot setup:"
	#
	echo_status "Extracting yaboot boot loader images."
	mkdir -p boot etc
	tar --use-compress-program=bzip2 \
	    -xf $base/build/${ROCKCFG_ID}/ROCK/pkgs/yaboot.tar.bz2 \
	    usr/lib/yaboot/yaboot -O > boot/yaboot
	tar --use-compress-program=bzip2 \
	    -xf $base/build/${ROCKCFG_ID}/ROCK/pkgs/yaboot.tar.bz2 \
            usr/lib/yaboot/yaboot.rs6k -O > boot/yaboot.rs6k
	#
	echo_status "Creating yaboot config file."
	cp -v $base/target/$target/powerpc/{yaboot.conf,boot.msg,ofboot.b} \
	  boot
	echo_status "Creating the IBM RS/6k yaboot config file."
	cp -v $base/target/$target/powerpc/yaboot.conf etc
	echo "Duplicates of /boot used on IBM RS/6k hardware." > etc/README
	#
	echo_status "Moving image (initrd) to yaboot directory."
	mv -v initrd.gz boot/
	#
	echo_status "Copy more config files."
	cp -v $base/target/$target/powerpc/mapping .
	#
	datdir="build/${ROCKCFG_ID}/ROCK/bootdisk"
	cat > ../isofs_arch.txt <<- EOT
		BOOT	-hfs -part -map $datdir/mapping -hfs-volid "ROCK_Linux_CD"
		BOOTx	-hfs-bless boot -sysid PPC
		BOOTx	-prep-boot boot/yaboot -prep-boot boot/yaboot.rs6k
		DISK1	$datdir/boot/ boot/
	EOT
#		SCRIPT  sh $base/target/bootdisk/powerpc/bless-rs6k.sh $disksdir
fi

