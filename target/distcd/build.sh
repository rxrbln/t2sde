source misc/target/functions
[ -f target/$target/functions ] && source target/$target/functions

#rm -rf $imagedir
#mkdir -p $imagedir

image_parse_cfg target/$target/initrd.cfg
exit

pkgsel_update_tmpl   # rerun config if pkgsel.tmpl was updated
pkgloop              # build it

# bend PATH so we use utils we build ourselves
export PATH="$build_rock/tools.cross/bin:$base/build/${ROCKCFG_ID}/TOOLCHAIN/tools.cross/diet-bin:$PATH"
# set DIETHOME in case we use diet
export DIETHOME="$base/build/${ROCKCFG_ID}/usr/dietlibc"

# 








# Create ISO structure
#iso_prepare_bootable
#FIXME dummy entry
#iso_add DISK1 $topdir/COPYING /
