
disksdir="$build_rock/livecd"

if [ -z "`which create_compressed_fs`" ] ; then
	echo "Please make sure create_compressed_fs is installed! Rock Package: fake/cloop"
	exit 1;
fi ;

if [ -z "`which mkisofs`" ] ; then
	echo "Please make mkisofs is installed! Rock Package: base/cdrtools"
	exit 1;
fi;

pkgloop
rm -rf $disksdir; mkdir -p $disksdir; chmod 700 $disksdir

. scripts/parse-config

. $base/target/$target/build_stage2.sh

. $base/target/$target/build_stage1.sh

if [ -f $base/target/$target/$arch/build.sh ]; then
	. $base/target/$target/$arch/build.sh
fi

echo_header "Creating ISO filesystem description."
cd $disksdir; rm -rf isofs; mkdir -p isofs

echo_status "Creating livecd/isofs directory.."
ln 2nd_stage.img.z isofs/
ln *.img initrd.gz isofs/ 2>/dev/null || true

echo_status "Creating isofs.txt file .."
echo "DISK1	build/${ROCKCFG_ID}/ROCK/livecd/isofs/ `
	`${ROCKCFG_SHORTID}/" > ../isofs_generic.txt
cat ../isofs_*.txt > ../isofs.txt

