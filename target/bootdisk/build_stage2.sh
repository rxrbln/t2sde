
set -e
taropt="--use-compress-program=bzip2 -xf"

echo_header "Creating 2nd stage filesystem:"
mkdir -p $disksdir/2nd_stage
cd $disksdir/2nd_stage
mkdir -p mnt/source mnt/target
#
package_map='       +00-dirtree         +glibc22            +glibc23
-gcc2               -gcc3               -gcc33              -gccx
-linux24-src        -linux26-src        -linux24benh-src
-linux24-header     -linux26-header     -linux24benh-header
-linux24            -linux26            -linux24benh
-binutils           -bin86              -nasm               -dietlibc
+grub               +lilo               +yaboot             +aboot
+silo               +parted             +mac-fdisk          +pdisk
+xfsprogs           +mkdosfs            +jfsutils
+e2fsprogs          +reiserfsprogs      +genromfs           +lvm
+popt               +raidtools          +mdadm
+dump               +eject              +disktype
+hdparm             +memtest86          +cpuburn            +bonnie++
-mine               -bize               -termcap            +ncurses
+readline           -strace             -ltrace             -perl5
-m4                 -time               -gettext            -zlib
+bash               +attr               +acl                +findutils
+mktemp             +coreutils          -diffutils          -patch
-make               +grep               +sed                +gzip
+tar                +gawk               -flex               +bzip2
-texinfo            +less               -groff              -man
+nvi                -bison              +bc                 +cpio
+ed                 -autoconf           -automake           -libtool
+curl               +wget               +dialog             +minicom
+lrzsz              +rsync              +tcpdump            +module-init-tools
+sysvinit           +shadow             +util-linux         +wireless-tools
+net-tools          +procps             +psmisc             +rockplug
+modutils           +pciutils           -cron               +portmap
+sysklogd           +devfsd             +setserial          +iproute2
+netkit-base        +netkit-ftp         +netkit-telnet      +netkit-tftp
+sysfiles           +libpcap            +iptables           +tcp_wrappers
-kiss               +kbd		-syslinux           +ntfsprogs'

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
rm -rf home usr/{local,doc,man,info,games,share}
rm -rf var/adm/* var/games var/adm var/mail var/opt
rm -rf usr/{include,src} usr/*-linux-gnu {,usr/}lib/*.{a,la,o}
for x in usr/lib/*/; do rm -rf ${x%/}; done
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
	xargs rm -f
#
echo_status "Installing pci.ids ..."
tar $taropt ../../pkgs/pciutils.tar.bz2 \
	usr/share/pci.ids
#
echo_status "Creating 2nd stage linuxrc."
cp $base/target/$target/linuxrc2.sh linuxrc ; chmod +x linuxrc
cp $base/target/$target/shutdown sbin/shutdown ; chmod +x sbin/shutdown
echo '$STONE install' > etc/stone.d/default.sh
#
echo_status "Creating 2nd_stage.tar.gz archive."
tar -czf ../2nd_stage.tar.gz * ; cd ..


echo_header "Creating small 2nd stage filesystem:"
mkdir -p 2nd_stage_small ; cd 2nd_stage_small
mkdir -p dev proc tmp bin lib etc share
mkdir -p mnt/source mnt/target
ln -s bin sbin ; ln -s . usr

#

progs="agetty bash cat cp date dd df ifconfig ln ls $packager mkdir mke2fs \
       mkswap mount mv rm reboot route sleep swapoff swapon sync umount \
       eject chmod chroot grep halt rmdir sh shutdown uname killall5 \
       stone mktemp sort fold sed mkreiserfs cut head tail disktype"

progs="$progs fdisk sfdisk"

if [ $arch = ppc ] ; then
	progs="$progs mac-fdisk pdisk"
fi

if [ $packager = bize ] ; then
	progs="$progs bzip2 md5sum"
fi

echo_status "Copy the most important programs ..."
for x in $progs ; do
	fn=""
	[ -f ../2nd_stage/bin/$x ] && fn="bin/$x"
	[ -f ../2nd_stage/sbin/$x ] && fn="sbin/$x"
	[ -f ../2nd_stage/usr/bin/$x ] && fn="usr/bin/$x"
	[ -f ../2nd_stage/usr/sbin/$x ] && fn="usr/sbin/$x"

	if [ "$fn" ] ; then
		cp ../2nd_stage/$fn $fn
	else
		echo_error "\`- Program not found: $x"
	fi
done

#

echo_status "Copy the required libraries ..."
found=1 ; while [ $found = 1 ]
do
	found=0
	for x in ../2nd_stage/lib ../2nd_stage/usr/lib
	do
		for y in $( cd $x ; ls *.so.* 2> /dev/null )
		do
			if [ ! -f lib/$y ] &&
			   grep -q $y bin/* lib/* 2> /dev/null
			then
				echo_status "\`- Found $y."
				cp $x/$y lib/$y ; found=1
			fi
		done
	done
done
#
echo_status "Copy linuxrc."
cp ../2nd_stage/linuxrc .
echo_status "Copy /etc/fstab."
cp ../2nd_stage/etc/fstab etc
echo_status "Copy stone.d."
mkdir -p etc/stone.d
for i in gui_text mod_install mod_packages mod_gas default ; do
	cp ../2nd_stage/etc/stone.d/$i.sh etc/stone.d
done
#
echo_status "Creating links for identical files."
while read ck fn
do
	if [ "$oldck" = "$ck" ] ; then
		echo_status "\`- Found $fn -> $oldfn."
		rm $fn ; ln $oldfn $fn
	else
		oldck=$ck ; oldfn=$fn
	fi
done < <( find -type f | xargs md5sum | sort )
#
echo_status "Creating 2nd_stage_small.tar.gz archive."
tar -cf- * | gzip -9 > ../2nd_stage_small.tar.gz ; cd ..

