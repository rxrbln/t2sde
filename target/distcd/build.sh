#FIXME values that will come from config later on
ROCKCFG_TARGET_DISTCD_BOOTLOADER=syslinux
ROCKCFG_TARGET_DISTCD_BOOTTYPE=cd
ROCKCFG_TARGET_DISTCD_KERNELS=linux26

# update package selection ###########################################
cleanup=0 # set to 1 if package selection has changed
if test target/distcd/pkgsel.tmpl -nt target/distcd/pkgsel; then
    echo_header "Updating package selection..."
    grep -v -E "^(#.*)?([ \t].*)?$" target/distcd/pkgsel.tmpl \
	| awk '{ print $1 " " $3; }' \
	> target/distcd/pkgsel

    # rerun config
    scripts/Config -cfg distcd -oldconfig

    cleanup=1
    echo_status "Done."
fi

# compile ############################################################
pkgloop

# paths ##############################################################
PATH="$base/build/${ROCKCFG_ID}/TOOLCHAIN/tools.cross/diet-bin:$PATH"
PATH="$build_rock/tools.cross/bin:$PATH"
export PATH
export DIETHOME="$base/build/${ROCKCFG_ID}/usr/dietlibc"

disksdir=$build_rock/$target

initrddir=$disksdir/initrd
rootfsdir=$disksdir/rootfs
isofsdir=$disksdir/isofs
tmpdir=$disksdir/tmp

topdir=$PWD

# prepare tmpdir
mkdir -p $tmpdir/boot

# functions ##########################################################
# unpack [--nocheck,--nostamp] [package [package ...]|all] 
unpack() { # unpacks packages into current directory!
    local a b c repo pkg ver d
    local file dounpack arg pkglist
    local nocheck=0 nostamp=0 cmd

    while [ $# -gt 0 ]; do
	case "$1" in
	    --nocheck)        nocheck=1 ; shift ;;
	    --nostamp)        nostamp=1 ; shift ;;
            *) break ;;
	esac
    done

    if [ "$1" = "all" ]; then # unpack all selected selected packages
	while read a b c repo pkg ver d; do
	    pkglist="$pkglist $pkg"
	done < <(grep "^X" $topdir/config/$config/packages)
	cmd=unpack
	[ $nocheck = 1 ] && cmd="$cmd --nocheck"
	[ $nostamp = 1 ] && cmd="$cmd --nostamp"
	eval "$cmd $pkglist"
    else
	for arg; do
	    read a b c repo pkg ver d < <(grep -E "^X.* $arg " $topdir/config/$config/packages)
	    file=`echo $build_rock/pkgs/$pkg-$ver.*`
	    dounpack=1

	    # check if in pkgsel template
	    if [ $nocheck = 0 ]; then
		if grep -q "^X O $pkg" $topdir/target/$target/pkgsel.tmpl; then # pkg deselected in pkgsel.tmpl
		    dounpack=0
		else
		    if grep -q "^X O $repo/*" $topdir/target/$target/pkgsel.tmpl; then # repo deselected in pkgsel.tmpl
			if ! grep -q "^X X $pkg" $topdir/target/$target/pkgsel.tmpl; then # but eventually not the pkg
			    dounpack=0
			fi
		    fi
		fi
	    fi

	    if [ $file -nt .stamp -o $nostamp = 1 ]; then # file is newer or --nostamp given
		if [ $dounpack -eq 1 ]; then
		    echo "  unpacking $pkg";
		    
		    #FIXME .gem files...
		    tar xfj $file
		else
		    echo "  skipping $pkg";
		fi
	    fi
	done
    fi

    touch .stamp
}

# cleanup ############################################################
if [ $cleanup -eq 1 ]; then
    [ -e "$rootfsdir" ] && rm -rf $rootfsdir
    [ -e "$isofsdir" ] && rm -rf $isofsdir
fi

# temporary ##########################################################
echo_header "Temporary files..."
pushd $tmpdir >/dev/null

    # kernels - only parts of it needed in different contexts
    for each in $ROCKCFG_TARGET_DISTCD_KERNELS; do
	unpack --nocheck $each
    done

    # only the bootloader itself is needed
    [ "$ROCKCFG_TARGET_DISTCD_BOOTLOADER" = "syslinux" ] && unpack --nocheck syslinux
    [ "$ROCKCFG_TARGET_DISTCD_BOOTLOADER" = "grub" ] && unpack --nocheck grub
    #FIXME other bootloaders

popd >/dev/null
echo_status "Done."

# initrd #############################################################
# make_initrd kernel-tree kernel-version extra-version
function make_initrd() {
    local ktree=$1 kver=$2

    if [ $cleanup = 1 ]; then
	rm -rf $initrddir-$kver
    fi

    echo_header "Creating initrd directory..."
    mkdir -p $initrddir-$kver/{dev,proc,sys,udev,rootfs,lib/modules/$kver}
    mkdir -p $initrddir-$kver/mnt/{source,target}

    # gather packages to put on initrd
    initrd_pkgs="`grep -E "^X .*(INITRD|INITRD-$ktree)[ \t]*$" target/distcd/pkgsel.tmpl | awk '{ print $3; }'`"

    pushd $initrddir-$kver >/dev/null
    
	echo_status "Exploding packages..."
	unpack $initrd_pkgs
	
	# kernel settings
	grep -q "CONFIG_CRAMFS=y"   $tmpdir/boot/kconfig_$kver && USE_CRAMFS=y
	grep -q "CONFIG_SQUASHFS=y" $tmpdir/boot/kconfig_$kver && USE_SQUASH=y
	grep -q "CONFIG_SQUASHFS=m" $tmpdir/boot/kconfig_$kver && USE_SQUASH=m
	grep -q "CONFIG_DEVFS_FS=m" $tmpdir/boot/kconfig_$kver && USE_DEVFS=m
	grep -q "CONFIG_DEVFS_FS=y" $tmpdir/boot/kconfig_$kver && USE_DEVFS=y

	# sanity check
	if [ "$USE_CRAMFS" != "y" -a "$USE_SQUASHFS" != "y" ]; then
	    echo_error "Kernel needs at least one: cramfs, squashfs"
	    exit -1
	fi
	
        # MAYBE remove not necesarily needed modules
	cp -a $tmpdir/lib/modules/$kver/ lib/modules/$kver

	echo_status "Cleanup initrd..."
	# remove documentation
	for each in usr/share/doc usr/share/man usr/share/texinfo; do
	    [ -e "$each" ] && rm -rf $each
	done
	# remove adm and sources
	[ -e var/adm ] && rm -rf var/adm
	[ -e usr/src ] && rm -rf usr/src
	
        # remove development files
	rm -rf usr/include
	rm -f usr/lib/*.a
	rm -f usr/lib/*.la
	
	echo_status "Creating init..."
	CFLAGS="-Os -s -I$topdir/target/$target/src"
	[ "$USE_DEVFS" = "y" ] && CFLAGS="$CFLAGS -DUSE_DEVFS"
	[ "${ROCKCFG_TARGET_DISTCD_BOOTTYPE}" != "${ROCKCFG_TARGET_DISTCD_BOOTTYPE//cd/}" ] \
	    && CFLAGS="$CFLAGS -DUSE_CDROM"
	CFLAGS="$CFLAGS -DDEBUG" # FIXME remove
	
	$CC -static -Os -s $CFLAGS -o sbin/init $topdir/target/$target/src/linuxrc.c

    popd > /dev/null
    echo_status Done.
}

#FIXME loop over kernels...
make_initrd 26 2.6.10-dist && var_append initrd_images ' ' "2.6.10-dist"

# rootfs #############################################################
#echo_header "Creating rootfs directory..."
#mkdir -p $rootfsdir
#pushd $rootfsdir >/dev/null
#
#    echo_status "Untarring packages..."
#    unpack all
#
#    [ -f $topdir/target/$target/rootfs/build.sh ] && . $topdir/target/$target/rootfs/build.sh
#
#popd > /dev/null
#FIXME compress->squashfs
#echo_status Done.

# architecture specific setup ########################################
if [ -f target/$target/arch/$ROCKCFG_ARCH/build.sh ]; then
    . target/$target/arch/$ROCKCFG_ARCH/build.sh
else
    echo_error "Architecture $ROCKCFG_ARCH not supported, sorry :("
    exit -1
fi

# FIXME should not be here: ##########################################
# FIXME should not be here: ##########################################
# FIXME should not be here: ##########################################
echo_header "Creating ISO-CD ..."
pushd $isofsdir >/dev/null

    mkisofs -J -hide-rr-moved -R \
	-b boot/isolinux/isolinux.bin -c boot/isolinux/boot.cat \
	-no-emul-boot -boot-load-size 4 -boot-info-table \
	-o $topdir/iso/$target-$ROCKCFG_ID.iso \
	.

popd >/dev/null
echo_status "Done."

