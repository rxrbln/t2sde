
use_yaboot=1

cd $disksdir

echo_header "Creating cleaning boot directory:"
rm -rfv boot/*-rock boot/System.map boot/kconfig*

if [ $use_yaboot -eq 1 ]
then
	echo_header "Creating yaboot setup:"
	#
	echo_status "Extracting yaboot boot loader."
	mkdir -p boot
	tar --use-compress-program=bzip2 \
	    -xf $base/build/${ROCKCFG_ID}/pkgs/yaboot.tar.bz2 \
	    usr/lib/yaboot/yaboot -O > boot/yaboot
	#
	echo_status "Creating yaboot config file."
	cp -v $base/target/$target/powerpc/{yaboot.conf,boot.msg,ofboot.b} \
	  boot
	#
	echo_status "Moving image (initrd) to yaboot directory."
	mv -v initrd.img boot/
	#
	echo_status "Copy more config files."
	cp -v $base/target/$target/powerpc/mapping .
	#
	datdir="build/${ROCKCFG_ID}/bootdisk"
	cat > ../isofs_arch.txt <<- EOT
		BOOT	-hfs -part -map $datdir/mapping -hfs-volid "ROCK_Linux_CD"
		BOOTx	-hfs-bless boot -sysid PPC
		DISK1	$datdir/boot/ boot/
	EOT
fi

