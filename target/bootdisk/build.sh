
disksdir="$build_dir/bootdisk"

if [ "$ROCK_DEBUG_BOOTDISK_NOSTAGE2" != 1 -a \
     "$ROCK_DEBUG_BOOTDISK_NOSTAGE1" != 1 ]
then
	pkgloop
	rm -rf $disksdir; mkdir -p $disksdir; chmod 700 $disksdir
fi

# Re-evaluate CC and other variables (as we have built the cross cc now)
. scripts/parse-config

# Add tools.cross/diet-bin/ to path so we find our 'diet' program
PATH="$base/build/${ROCKCFG_ID}/$toolsdir/diet-bin:$PATH"


if [ "$ROCK_DEBUG_BOOTDISK_NOSTAGE2" != 1 ]
then
	. $base/target/$target/build_stage2.sh
fi

if [ "$ROCK_DEBUG_BOOTDISK_NOSTAGE1" != 1 ]
then
	. $base/target/$target/build_stage1.sh
fi

if [ -f $base/target/$target/$arch/build.sh ]; then
	. $base/target/$target/$arch/build.sh
fi


echo_header "Creating ISO filesystem description."
cd $disksdir; rm -rf isofs; mkdir -p isofs

echo_status "Creating bootdisk/isofs directory.."
ln 2nd_stage.tar.gz 2nd_stage_small.tar.gz *.img isofs/

echo_status "Creating isofs.txt file .."
echo "DISK1	build/${ROCKCFG_ID}/bootdisk/isofs/ `
	`${ROCKCFG_SHORTID}/" > ../isofs_generic.txt
cat ../isofs_*.txt > ../isofs.txt

