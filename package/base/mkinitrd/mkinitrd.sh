#!/bin/bash
# --- T2-COPYRIGHT-BEGIN ---
# t2/package/*/mkinitrd/mkinitrd.sh
# Copyright (C) 2005 - 2025 The T2 SDE Project
# Copyright (C) 2005 - 2021 René Rebe <rene@exactcode.de>
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

set -e

map=`mktemp`
firmware=
microcode=
minimal=
network=1
archprefix=
outfile=
compressor="zstd -T0 -19"

# vital modules that need firmware
declare -A vitalmods
vitalmods[ast.ko]=1	# many modern servers
vitalmods[qla1280.ko]=1 # Sgi Octane, Origin, DEC Alpha
vitalmods[qla2xxx.ko]=1 # Sun Blade, T4
vitalmods[tg3.ko]=1	# Sun Fire
vitalmods[xhci-pci.ko]=1 # probably every modern machine
vitalmods[r8152.ko]=1
vitalmods[r8169.ko]=1

# TODO: defauls for vintage vs. latest, usb, pata, etc.
filter="-e /loop -e ext2 -e ext4 -e /xfs -e isofs -e nfsv4 -e zram -e pata_legacy
-e pata_.*platform -e pata_macio -e mac_esp -e sym53c8xx -e /aic7xxx -e qla1280
-e pci-host-generic -e virtio_pci_.*_dev -e virtio_pci -e virtio_blk -e sunvdc
-e s[rd]_mod -e /ahci.ko -e /nvme.ko -e [uoex]hci-[ph][c][id] -e usbhid
-e /offb -e /bochs -e ps3fb"

declare -A added

if [ $UID != 0 ]; then
	echo "Non root - exiting ..."
	exit 1
fi

while [ "$1" ]; do
  case $1 in
	[0-9]*) kernelver="$1" ;;
	-R) root="$2" ; shift ;;
	-a) archprefix="$2" ; shift ;;
	--firmware) firmware=1 ;;
	--minimal) minimal=1 ;;
	--network) network= ;;
	--microcode) microcode=1 ;;
	-e) filter="$filter $2" ; shift ;;
	-o) outfile="$2" ; shift ;;
	*) echo "Usage: mkinitrd [ --firmware ] [ --minimal ] [ --network ] [ -R root ] [ -e filter ] [ -o filename ] [ kernelver ]"
	   exit 1 ;;
  esac
  shift
done

# -e ps3vram -e net/phy
[ -z "$minimal" ] && filter="$filter -e reiserfs -e btrfs -e /jfs -e /xfs -e jffs2
-e /udf -e overlayfs -e ntfs -e /fat -e /hfs -e floppy -e efivarfs
-e pci/controller -e /ata/ -e /scsi/ -e /fusion/ -e /sdhci/ -e nvme/host -e /mmc/
-e virtio.\(blk\|scsi\|net\|console\|input\|gpu\|pci\) -e ps3disk -e drivers/pcmcia
-e dm-mod -e dm-raid -e md/raid -e dm/mirror -e dm/linear -e dm-crypt -e dm-cache
-e /aes -e /sha -e /blake -e /cbc -e /ecb -e xts
-e nls_cp437 -e nls_iso8859-1 -e nls_utf8
-e usb/host -e usb-common -e usb-storage -e firewire-ohci -e sbp2 -e uas -e thunderbolt\.
-e i2c-hid -e hid-generic -e hid-multitouch
-e hid-apple[^i] -e hid-microsoft -e hyperv-keyboard
-e cpufreq/[^_]\+$ -e hwmon.*temp -e /rtc/ -e input-leds -e /ast/"

[ "$network" ] && filter="$filter -e '/ipv4\.' -e '/ipv6\.' -e ethernet
-e aqc111 -e asix -e ax88179_178a -e cdc_ether -e /cdc_ncm -e cx82310_eth -e r8153_ecm -e rtl8150 -e r8152"

[ "$kernelver" ] || kernelver=`uname -r`
[ "$moddir" ] || moddir="$root/lib/modules/$kernelver"

if [ -z "$outfile" ]; then
    [ "$minimal" ] &&
	outfile="$root/boot/minird-$kernelver" ||
	outfile="$root/boot/initrd-$kernelver"
fi

modinfo="${archprefix}modinfo -b $moddir -k $kernelver"
depmod=${archprefix}depmod

echo "Kernel: $kernelver, module dir: $moddir"

if [ ! -d $moddir ]; then
	echo "Warning: $moddir does not exist!"
	moddir=""
fi

sysmap="$root/boot/System.map-$kernelver"
[ -f "$sysmap" ] || sysmap=

if [ -z "$sysmap" ]; then
	echo "System.map-$kernelver not found!"
	exit 2
fi

echo "System.map: $sysmap"

# check needed tools
for x in cpio ${compressor%% *}; do
	if ! type -p $x >/dev/null; then
		echo "$x not found!"
		exit 2
	fi
done

tmpdir="$map.d"
cd ${tmpdir%/*}
mkdir ${tmpdir##*/}
cd $tmpdir

# create basic structure
#
echo "Create dirtree ..."

mkdir -p {dev,bin,sbin,proc,sys,usr/sbin,lib/modules,lib/udev,etc/hotplug.d/default}
mknod dev/null c 1 3
mknod dev/zero c 1 5
mknod dev/tty c 5 0
mknod dev/console c 5 1

# copy the basic / rootfs kernel modules
#

if [ "$moddir" ]; then
 echo "Copying kernel modules ..."
 (
  add_depend() {
	local skipped=
	local x="$1" module="${1##*/}"

	[ "${added["$module"]}" ] && return
	added["$module"]=1

	# expand to full name if it was a depend, softdep may also built-in
	if [ $x = ${x##*/} ]; then
		x=`sed -n "/\/${x/./\\.}.*/{p; q}" $map`
		# found? e.g. no built-in softdep?
		[ -z "$x" ] && return
	fi

	echo -n "$module "

	# strip $root prefix
	xt=${x##$root}

	# does it need firmware?
	fw="`$modinfo -F firmware $x`"
	if [ "$fw" ]; then
	     echo -e -n "\nWarning: $module needs firmware"
	     if [ "$firmware" -o "${vitalmods[$module]}" ]; then
		for fn in $fw; do
		    local fn="/lib/firmware/$fn"
		    local dir="./${fn%/*}"
		    if [ ! -e "$root$fn" ]; then
			if [ "${vitalmods[$module]}" ]; then
			    echo ", not found, vital, including anyway"
			else
			    echo ", not found, skipped"
			    skipped=1
			fi
		    else
			mkdir -p "$dir"
			echo -n ", $fn"
			cp -af "$root$fn" "$dir/"
			# TODO: copy source if symlink
			[ -f "$tmpdir$fn" ] && $compressor --rm -f --quiet "$tmpdir$fn" &
		    fi
		done
		echo
	     else
		echo ", skipped"
		skipped=1
	     fi
	fi

	if [ -z "$skipped" ]; then
	    mkdir -p `dirname ./$xt` # TODO: use builtin?
	    cp -af $x $tmpdir$xt
	    $compressor --rm -f --quiet $tmpdir$xt &

	    # add deps: one are comma separated, the other pre: post: prefixed
	    for fn in $($modinfo -F depends $x | sed 's/,/ /g') \
		$($modinfo -F softdep $x | sed 's/.*: //'); do
		add_depend "$fn.ko"
	    done
	fi
  }

  find -H $moddir/ -type f -name '*.ko*' > $map
  grep -v -e /wireless/ -e netfilter $map | grep $filter |
  while read fn; do
	add_depend "$fn"
  done

  wait
 ) | fold -s; echo

 # generate map files
 #
 mkdir -p lib/modules/$kernelver
 cp -avf $moddir/modules.{order*,builtin*} lib/modules/$kernelver/
 $depmod -ae -b $tmpdir -F $sysmap $kernelver
 # only keep the .bin-ary files
 rm -vf $tmpdir/lib/modules/$kernelver/modules.{alias,dep,symbols,builtin,order,builtin.modinfo}
fi

echo "Injecting programs and configuration ..."

# copying config
#
cp -ar $root/etc/{group,udev} $tmpdir/etc/

[ -e $root/etc/os-release ] && cp -a $root/etc/os-release $tmpdir/etc/initrd-release
[ -e $root/lib/udev/rules.d ] && cp -ar $root/lib/udev/rules.d $tmpdir/lib/udev/
[ -e $root/etc/mdadm.conf ] && cp -ar $root/etc/mdadm.conf $tmpdir/etc/
cp -ar $root/etc/modprobe.* $root/etc/ld-* $tmpdir/etc/ 2>/dev/null || true

# in theory all, but fat and not all always needed ...
cp -a $root/lib/udev/{ata,scsi,cdrom}_id $tmpdir/lib/udev/

elf_magic () {
	readelf -h "$1" 2>/dev/null | grep 'Machine\|Class'
}

# copy dynamic libraries, and optional plugins, if any.
#
if [ "$minimal" ]; then
	extralibs="`ls $root/lib*/{libdl,libncurses.so}* 2>/dev/null || true`"
else
	# glibc only
	extralibs="`ls $root/{lib*/libnss_files,usr/lib*/libgcc_s}.so* 2>/dev/null || true`"
fi

copy_dyn_libs () {
	local magic
	# we can not use ldd(1) as it loads the object, which does not work on cross builds
	for lib in $(readelf -de $1 2>/dev/null |
		sed -n -e 's/.*Shared library.*\[\([^]\]*\)\]/\1/p' \
		    -e 's/.*Requesting program interpreter: \([^]]*\)\]/\1/p') $extralibs
	do
		# remove $root prefix from extra libs
		[ "$lib" != "${lib#$root/}" ] && lib="${lib##*/}"

		if [ -z "$magic" ]; then
			magic="$(elf_magic $1)"
			[[ $1 = *bin/* ]] && echo "Warning: $1 is dynamically linked!"
		fi
		for libdir in $root/lib*/ $root/usr/lib*/ "$root"; do
			if [ -e $libdir$lib ]; then
			    # resolve absolute sym-links relative to the sys-root
			    local rlib="$libdir$lib"
			    if [ -L "$rlib" ]; then
				rlib="$(readlink $rlib)"
				[[ "$rlib" = /* ]] && rlib="$libdir$rlib" || rlib="$libdir$lib"
			    fi
	
			    local magic2="$(elf_magic $rlib)"
			    [ "$magic" != "$magic2" ] && continue
			    xlibdir=${libdir#$root}

			    if [ -z "${added["$xlibdir$lib"]}" ]; then
				added["$xlibdir$lib"]=1

				echo "	${1#$root} NEEDS $xlibdir$lib"

				mkdir -p ./$xlibdir
				while local x=`readlink $libdir$lib`; [ "$x" ]; do
					echo "	$xlibdir$lib SYMLINKS to $x"
					local y=$tmpdir$xlibdir$lib
					mkdir -p ${y%/*}
					ln -sfv $x $tmpdir$xlibdir$lib
					if [ "${x#/}" == "$x" ]; then # relative?
						# directory to prepend?
						[ ${lib%/*} != "$lib" ] && x="${lib%/*}/$x"
					fi
					lib="$x"
				done
				local y=$tmpdir$xlibdir$lib
				mkdir -p ${y%/*}
				cp -af $libdir$lib $tmpdir$xlibdir$lib

				copy_dyn_libs $libdir$lib
			    fi
			fi
		done
	done
}

# setup programs
#
for x in $root/sbin/{udevd,udevadm,kmod,modprobe} $root/usr/sbin/{disktype,ipconfig}
do
	cp -av $x $tmpdir/sbin/
	copy_dyn_libs $x
done

# setup optional programs
#
[ -z "$minimal" ] &&
for x in $root/sbin/{insmod,blkid,lvm,vgchange,lvchange,vgs,lvs,mdadm} \
	 $root/usr/sbin/{cryptsetup,smartctl,cache_check} $root/usr/embutils/{dmesg,mkswap,swapon}
do
  if [ ! -e $x ]; then
	echo "Warning: Skipped optional file ${x#$root}!"
  else
	d="${x%/*}"; d="${d#$root}"
	d="${d/usr\/embutils/sbin}"
	cp -a $x $tmpdir/$d/
	copy_dyn_libs $x
  fi
done

# copy a small shell
for sh in $root/bin/{mksh,pdksh,bash}; do
    if [ -e "$sh" ]; then
	cp $sh $tmpdir/bin/${sh##*/}
	ln -sf ${sh##*/} $tmpdir/bin/sh
	break
    fi
done

# static, tiny embutils and friends
#
cp $root/usr/embutils/{mount,umount,rm,mv,mkdir,ln,ls,switch_root,pivot_root,chroot,sleep,losetup,chmod,cat,sed,mknod} \
   $tmpdir/bin/
ln -s mv $tmpdir/bin/cp

cp $root/sbin/initrdinit $tmpdir/init
chmod +x $tmpdir/init

# Custom ACPI DSDT table
if test -f "$root/boot/DSDT.aml"; then
	echo "Adding local DSDT file: $dsdt"
	cp $root/boot/DSDT.aml $tmpdir/DSDT.aml
fi

# create / truncate
echo -n > "$outfile"

if true; then
    if [ "$microcode" ]; then
	microcode="$outfile"
    else
	microcode="$root/boot/microcode.img"
	rm -f "$microcode"
    fi

    # include cpu microcode, if available, ...
    if [ -d $root/lib/firmware/amd-ucode ]; then
	mkdir -p $tmpdir/kernel/x86/microcode
	cat $root/lib/firmware/amd-ucode/microcode_amd*.bin > $tmpdir/kernel/x86/microcode/AuthenticAMD.bin
    fi

    if [ -d $root/lib/firmware/intel-ucode ]; then
	mkdir -p $tmpdir/kernel/x86/microcode
	cat $root/lib/firmware/intel-ucode/* > $tmpdir/kernel/x86/microcode/GenuineIntel.bin
    fi

    if [ -d $tmpdir/kernel/x86/microcode ]; then
    (
	cd $tmpdir
	find kernel | cpio -o -H newc >> $microcode
    )
    fi
    rm -rf $tmpdir/kernel
fi

# create the cpio image
#
echo "Archiving ..."
( cd $tmpdir
  # sorted by priority in case of out-of-memory
  find init proc sys dev *bin usr etc lib* \( -path lib/modules -o -path lib/firmware \) -prune -o -print
  find lib/[mf]*
) | (
  cd $tmpdir
  cpio -o -H newc | $compressor >> "$outfile"
)
rm -rf $tmpdir $map
