
set -e
taropt="--use-compress-program=bzip2 -xf"

echo_header "Creating 2nd stage filesystem:"
mkdir -p $disksdir/2nd_stage
cd $disksdir/2nd_stage
mkdir -p mnt/source mnt/target ramdisk

. $base/target/$target/default.pkgmap

if [ -f ../../pkgs/bize.tar.bz2 -a ! -f ../../pkgs/mine.tar.bz2 ] ; then
	packager=bize
else
	packager=mine
fi

package_map="+$ROCKCFG_DEFAULT_KERNEL +$packager $package_map"

echo_status "Extracting the packages archives."
for x in $( ls ../../pkgs/*.tar.bz2 | tr . / | cut -f8 -d/ )
do
	if echo "" $package_map "" | grep -q " +$x "
	then
		echo_status "\`- Extracting $x.tar.bz2 ..."
		tar --use-compress-program=bzip2 -xpf ../../pkgs/$x.tar.bz2
	elif ! echo "" $package_map "" | grep -q " -$x "
	then
		echo_error "\`- Not found in \$package_map: $x"
		echo_error "    ... fix target/$target/build.sh"
	fi
done
#
echo_status "Saving boot/* - we do not need this on the 2nd stage ..."
rm -rf ../boot ; mkdir ../boot
mv boot/* ../boot/
#
echo_status "Remove the stuff we do not need ..."
rm -rf home usr/{doc,man,info}
rm -rf var/adm/* var/adm var/mail 
rm -rf usr/{include,src} usr/*-linux-gnu {,usr/}lib/*.{a,la,o} opt/*/lib/*.{a,la,o}
#for x in usr/lib/*/; do rm -rf ${x%/}; done
#
echo_status "Installing some terminfo databases ..."
tar $taropt ../../pkgs/ncurses.tar.bz2	\
	usr/share/terminfo/x/xterm	usr/share/terminfo/a/ansi	\
	usr/share/terminfo/n/nxterm	usr/share/terminfo/l/linux	\
	usr/share/terminfo/v/vt200	usr/share/terminfo/v/vt220	\
	usr/share/terminfo/v/vt100	usr/share/terminfo/s/screen
#
echo_status "Installing some keymaps ..."
tar $taropt ../../pkgs/kbd.tar.bz2 \
	usr/share/kbd/keymaps/amiga	usr/share/kbd/keymaps/i386/qwerty \
	usr/share/kbd/keymaps/atari	usr/share/kbd/keymaps/i386/qwertz \
	usr/share/kbd/keymaps/sun
find usr/share/kbd -name '*dvo*' -o -name '*az*' -o -name '*fgG*' | \
	xargs rm -rf
#
echo_status "Installing pci.ids ..."
tar $taropt ../../pkgs/pciutils.tar.bz2 \
	usr/share/pci.ids
echo_status "replacing some vital files for live useage ..."
cp -f $base/target/$target/fixedfiles/inittab etc/inittab
cp -f $base/target/$target/fixedfiles/login-shell sbin/login-shell
cp -f $base/target/$target/fixedfiles/system etc/rc.d/init.d/system
cp -f $base/target/$target/fixedfiles/XF86Config etc/X11/XF86Config
#
### DOC ### create_compressed_fs and mkisofs need to be in path !!! ### DOC ###
echo_status "Creating 2nd_stage.img.z image... (this takes some time)... "
cd .. ; ( mkisofs -R -l 2nd_stage | create_compressed_fs - 65536 > 2nd_stage.img.z ) > /dev/null 2>&1

