
use_silo=1

cd $disksdir

echo_header "Creating cleaning boot directory:"
rm -rfv boot/*-rock boot/System.map boot/kconfig*

if [ $use_silo -eq 1 ]
then
	echo_header "Creating silo setup:"
	#
	echo_status "Extracting silo boot loader images."
	mkdir -p boot
	tar --use-compress-program=bzip2 \
	    -xf $base/build/${ROCKCFG_ID}/pkgs/silo.tar.bz2 \
	    boot/second.b -O > boot/second.b
	#
	echo_status "Creating silo config file."
	cp -v $base/target/$target/sparc/{silo.conf,boot.msg} \
	  boot
	#
	# echo_status "Moving image (initrd) to boot directory."
	# mv -v initrd.img boot/
	#
	buildroot="build/${ROCKCFG_ID}"
	datadir="build/${ROCKCFG_ID}/ROCK/bootdisk"
	cat > ../isofs_arch.txt <<- EOT
		BOOT	-G $buildroot/boot/isofs.b -B ...
		DISK1	$datdir/boot/ boot/
	EOT
fi

