# --- T2-COPYRIGHT-BEGIN ---
# t2/package/*/grub2/stone_mod_grub2.sh
# Copyright (C) 2004 - 2025 The T2 SDE Project
# Copyright (C) 1998 - 2003 ROCK Linux Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---
#
# [MAIN] 70 grub2 GRUB2 Boot Loader Setup
# [SETUP] 90 grub2

# TODO:
# avoid efibootmgr duplicates :-/
# impl. & test direct sparc, direct i386-pc-mbr, mips-arc, ...
# unify non-crypt, and direct non-EFI BIOS install

arch=$(uname -m)
arch=${arch/i?86/i386}
arch=${arch/aarch/arm}

# detect platform once, Attn, SYNC w/ stone_mod_install!
platform2=$(grep '\(platform\|type\)' /proc/cpuinfo) platform2=${platform2##*: }
[ -e /sys/firmware/efi ] && platform=$arch-efi ||
case $arch in
	ppc*)
		arch="$arch-$platform2" ;;
esac

cmdline="console= $(< /proc/cmdline)"
cmdline=${cmdline##*console=} cmdline=${cmdline%%[ ,]*}
if [ -z "$cmdline" ]; then
	cmdline="`grep -a -H Y /sys/class/tty/*/console`"
	cmdline="${cmdline%%/console*}" cmdline=${cmdline##*/}
fi

create_kernel_list() {
	local first=1 default=
	for x in vmlinux $(cd /boot; ls vmlinux?* | sort -Vr); do
		[ "$default" ] || default=$(readlink /boot/$x)
		[ "$default" = "$x" ] && continue
		local ver=${x#vmlinux}; ver=${ver#-}
		[ -e /boot/${x/vmlinux/vmlinuz} ] && x=${x/vmlinux/vmlinuz}
		if [ $first = 1 ]; then
			label="Linux" first=0
		else
			label="Linux ($ver)"
		fi

		local initrd="$bootpath/initrd${ver:+-$ver}"
		[ -e /boot/microcode.img ] && initrd="/boot/microcode.img $initrd"

		cat << EOT

menuentry "T2/$label" {
	linux $bootpath/$x root=$rootdev ro${swapdev:+ resume=$swapdev}${cmdline:+ console=}$cmdline
	initrd $initrd
}
EOT
	done
}

create_boot_menu() {
	mkdir -p /boot/grub/
	cat << EOT > /boot/grub/grub.cfg
set timeout=8
set default=0
set fallback=1

if [ "\$grub_platform" = "efi" ]; then
    set debug=video
    insmod efi_gop
    insmod efi_uga
    insmod font
    if loadfont \${prefix}/unicode.pf2; then
	insmod gfxterm
	set gfxmode=auto
	set gfxpayload=keep
	terminal_output gfxterm
    fi
fi

EOT

	create_kernel_list >> /boot/grub/grub.cfg

	gui_message "This is the new /boot/grub/grub.cfg file:

$(cat /boot/grub/grub.cfg)"
}

grubmods="normal boot configfile linux part_msdos part_gpt \
	  fat ext2 iso9660 reiserfs btrfs xfs jfs \
	  search search_fs_file search_label search_fs_uuid \
	  all_video sleep reboot \
	  cryptodisk lvm luks luks2 crypto"

case "$arch" in
	ppc*)	grubmods="$grubmods part_apple hfs hfsplus suspend" ;;
	sparc*)	grubmods="$grubmods part_sun" ;;
	x86*)	grubmods="$grubmods ntfs ntfscomp" ;;
esac

grub_inst() {
    if [[ $arch != ppc* ]]; then
	if [[ ! "$cryptdev" && "$instdev" != *efi ]]; then
	    if [[ "$arch" != sparc* ]]; then
		grub2-install $instdev
	    else
		grub2-install $instdev --skip-fs-probe --force
	    fi
	else
	    mount -t efivarfs none /sys/firmware/efi/efivars

	    for efi in ${instdev}*; do
		mount -o remount,rw $efi
		mkdir -p $efi/efi/boot

		echo -n > $efi/efi/boot/grub.cfg

		if [ ! "$cryptdev" ]; then
			# if uuid, not LVM search it
			[[ "$grubdev" != \(* ]] &&
			cat << EOT >> $efi/efi/boot/grub.cfg
set uuid=$grubdev
search --set=root --no-floppy --fs-uuid \$uuid
EOT
		else
	    		cat << EOT >> $efi/efi/boot/grub.cfg
set uuid="${cryptdev##*/}"
if cryptomount -u \$uuid; then set root=(crypto0); fi
EOT
		fi

		# explicitly set root for lvm
		if [[ "$grubdev" = \(lvm* ]]; then
			echo "set root=$grubdev" >> $efi/efi/boot/grub.cfg
		fi

		echo "configfile /boot/grub/grub.cfg" >> $efi/efi/boot/grub.cfg

		local exe=boot.efi
		case $arch in
		i386)	exe=${exe/./ia32.} ;;
		ia64)	exe=${exe/./ia64.} ;;
		x86_64)	exe=${exe/./x64.} ;;
		arm64)	exe=${exe/./aa64.} ;;
		arm*)	exe=${exe/./arm.} ;;
		riscv*)	exe=${exe/./$arch.} ;;
		esac

		mkdir -p $efi/efi/boot/$arch-efi
		cp -f /usr/lib*/grub/$arch-efi/*.{mod,lst} \
			$efi/efi/boot/$arch-efi/

		grub-mkimage -O $arch-efi -o $efi/efi/boot/$exe \
			-p /efi/boot -d /usr/lib*/grub/$arch-efi/ \
			--compression auto $grubmods

		local dev=$(grep "$efi " /proc/mounts | sed 's/ .*//;q')
		local p=${dev##*[!0-9]}
		local d=${dev%$p}
		[ ! -e $d ] && d=${dev%p} # new-style, nvme p part separator?
	    	efibootmgr -c -L "T2 Linux" -d $d -p $p -l "\\efi\\boot\\$exe"
	    done

	    # remove possible duplicates, sigh
	    efibootmgr | grep "T2 Linux" | sed 's/.*[[:space:]]//' |
		sort | uniq -c | grep -v ' 1 ' | sed 's/.*[[:space:]]//' |
		while read -r dup; do
			# re-list dups again
			efibootmgr | grep "${dup//\\/\\\\}" | sed 's/[ *].*//; $d'
		done | while read bootnum; do
			echo "removing duplicate $bootnum"
			efibootmgr -q -b ${bootnum#Boot} -B # delete
		done

	    umount /sys/firmware/efi/efivars
	fi
    else
      [ -e $instdev ] || instdev=/dev/sda # TODO: fix LVM setup

      if [[ "$arch" = *CHRP || "$arch" = *pSeries ]]; then
	# IBM CHRP install into FW read-able RAW partition
	local bootstrap=$(fdisk -l $instdev | sed -n '/PReP boot/s/ .*//p')
	if [ "$bootstrap" = "$instdev" ]; then
		echo "No CHRP PReP bootstrap partition found!"
		return
	fi

	# TODO: tempfile, built-in config script -c
	grub-mkimage --note -O powerpc-ieee1275 -p /boot/grub \
		-o /tmp/grub -d /usr/lib*/grub/powerpc-ieee1275 \
		--compression auto $grubmods

	dd if=/dev/zero of=$bootstrap bs=4096
	dd if=/tmp/grub of=$bootstrap bs=4096
	rm -f /tmp/grub

	# update OF boot-device
	nvsetenv boot-device "$(ofpathname $bootstrap)"
      else
	# Apple PowerPC - install into FW read-able HFS partition
	local bootstrap=$instdev$(disktype $instdev | grep Apple_Bootstrap -B 1 |
		sed -n 's/Partition \(.*\):.*/\1/p')
	if [ "$bootstrap" = "$instdev" ]; then
		echo "No HFS bootstrap partition found!"
		return
	fi
	
	umount /mnt 2>/dev/null
	hformat -l bootstrap $bootstrap
	if ! mount $bootstrap /mnt; then
	    echo "Error mounting HFS bootstrap partition"
	else
	    mkdir -p /mnt/boot/grub
	    if [ -z "$cryptdev" ]; then
		cat << EOT > /mnt/boot/grub/grub.cfg
set root=$grubdev
search --set=root --no-floppy --fs-uuid \$root
configfile (\$root)/boot/grub/grub.cfg
EOT
	    else
		cat << EOT > /mnt/boot/grub/grub.cfg
set uuid=$grubdev
cryptomount -u \$uuid
configfile $cryptdev/boot/grub/grub.cfg
EOT
	    fi
	    grub-mkimage -O powerpc-ieee1275 -p /boot/grub \
		-o /mnt/grub -d /usr/lib*/grub/powerpc-ieee1275 \
		-c /mnt/boot/grub/grub.cfg --compression auto $grubmods

	    cat > /mnt/boot/ofboot.b <<-EOT
<CHRP-BOOT>
<COMPATIBLE>
MacRISC MacRISC3 MacRISC4
</COMPATIBLE>
<DESCRIPTION>
T2 SDE
</DESCRIPTION>
<BOOT-SCRIPT>
" screen" output
load-base release-load-area
boot &device;:,\\grub
</BOOT-SCRIPT>
<OS-BADGE-ICONS>
1010
00000000000000000000000000000000
00000000000000000000000000000000
23232323232323230005001c23c6c600
232323232323232300051c1c1cc6c6c6
0000000000000000051c1c230000c6c6
000000c6c6000000051c2300000000c6
000000c6c6000005050500000000c6c6
000000c6c60000050500000000c6c6c6
000000c6c600000505000000c6c6c600
000000c6c6000505000000c6c6c60000
000000c6c60005050000c6c6c6000000
000000c6c605050000c6c6c600000000
000000c6c60505000000000000000000
000000c6c60500000505050505050500
000000c6c60500050505050505050500
00000000000000000000000000000000
f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8
f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8
dadadadadadadadaf859f864dacecef8
dadadadadadadadaf859646464cecece
f8f8f8f8f8f8f8f8596464daf8f8cece
f8f8f8cecef8f8f85964daf8f8f8f8ce
f8f8f8cecef8f8595959f8f8f8f8cece
f8f8f8cecef8f85959f8f8f8f8cecece
f8f8f8cecef8f85959f8f8f8cececef8
f8f8f8cecef85959f8f8f8cececef8f8
f8f8f8cecef85959f8f8cececef8f8f8
f8f8f8cece5959f8f8cececef8f8f8f8
f8f8f8cece5959f8f8f8f8f8f8f8f8f8
f8f8f8cece59f8f859595959595959f8
f8f8f8cece59f85959595959595959f8
f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8
00000000000000000000000000000000
00000000000000000000000000000000
ffffffffffffffff00ff00ffffffff00
ffffffffffffffff00ffffffffffffff
0000000000000000ffffffff0000ffff
000000ffff000000ffffff00000000ff
000000ffff0000ffffff00000000ffff
000000ffff0000ffff00000000ffffff
000000ffff0000ffff000000ffffff00
000000ffff00ffff000000ffffff0000
000000ffff00ffff0000ffffff000000
000000ffffffff0000ffffff00000000
000000ffffffff000000000000000000
000000ffffff0000ffffffffffffff00
000000ffffff00ffffffffffffffff00
00000000000000000000000000000000
</OS-BADGE-ICONS>
</CHRP-BOOT>
EOT

	    umount /mnt
	    hmount $bootstrap
	    hattrib -b bootstrap:boot
	    hattrib -c UNIX -t tbxi bootstrap:boot:ofboot.b
	    humount

	    # update OF boot-device
	    nvsetenv boot-device "$(ofpathname $bootstrap),\\\\:tbxi"
	fi
      fi
    fi
}

grub_install() {
	gui_cmd 'Installing GRUB2' "grub_inst"
}

get_dm_dev() {
	local dev
	[ ! -L $1 ] && dev=$1 || dev=$(readlink $1)
	local devnode=$(stat -c "%t:%T" $dev)
	for d in /dev/dm-*; do
		[ "$(stat -c "%t:%T" "$d" 2>/dev/null)" = "$devnode" ] && echo $d && return
	done
}

get_dm_type() {
	local dev="$1"
	dev="${dev##*/}"
	[ -e /sys/block/$dev/dm/uuid ] && cat /sys/block/$dev/dm/uuid
}

get_dm_slaves() {
	local dev="$1"
	dev="${dev##*/}"
	[ -e /sys/block/$dev/slaves ] &&
		cd /sys/block/$dev/slaves && ls | sed 's,^,/dev/,'
}

get_crypted_dm_slaves() {
	for d; do
	    [[ "$(blkid --match-tag TYPE $d)" = *crypto_LUKS* ]] &&
		  echo "$d" ||
		  get_crypted_dm_slaves $(get_dm_slaves $d)
	done
}

get_uuid() {
	local dev="$1"

	# look up uuid
	for _dev in /dev/disk/by-uuid/*; do
		local d=$(readlink $_dev)
		d="/dev/${d##*/}"
		if [ "$d" = $dev ]; then
			echo $_dev
			return
		fi
	done
}

get_realdev() {
	local dev="$1"
	dev=$(readlink $dev)
	[ "$dev" ] && echo /dev/${dev##*/} || echo $1
}

main() {
	rootdev="`grep ' / ' /etc/fstab | tail -n 1 | sed 's, .*,,'`"
	bootdev="`grep ' /boot ' /etc/fstab | tail -n 1 | sed 's, .*,,'`"
	swapdev="`grep ' swap ' /etc/fstab | grep -v dev/zram  | head -n 1 | sed 's, .*,,'`"
	[ "$bootdev" ] || bootdev="$rootdev"
	# /boot path, relative to the boot device
	[ "$rootdev" = "$bootdev" ] && bootpath="/boot" || bootpath=""

	# any device-mapper luks encrypted backing slave device?
	cryptdev=$(get_crypted_dm_slaves $bootdev $(get_dm_dev $bootdev))

	# get uuid
	uuid=$(get_uuid $rootdev)
	[ "$uuid" ] && rootdev=$uuid
	[ "$bootdev" ] && uuid=$(get_uuid $bootdev) && [ "$uuid" ] && bootdev=$uuid
	[ "$cryptdev" ] && uuid=$(get_uuid $cryptdev) && [ "$uuid" ] && cryptdev=$uuid

	instdev=$(get_realdev $bootdev)
	instdev="${instdev%%[0-9*]}"
	if [ -d /sys/firmware/efi ]; then
		instdev=/boot/efi
	elif [[ "$arch" = sparc* ]] && ! disktype $instdev | grep -q "^GPT part"; then
		# old disklabel, non sun4v-gpt SPARC boot via blocklist
		instdev="${instdev}1"
	fi

	# lvm device-mapper?
	if [[ "$(readlink $bootdev)" = *mapper* ]]; then
	        grubdev="${bootdev#/dev/}"
		grubdev="${grubdev//-/--}"
		grubdev="(lvm/${grubdev//\//-})"
		[ "$cryptdev" ] && rootdev="$cryptdev,$rootdev"
	else
		grubdev="${bootdev##*/}"
	fi

	if [ ! -f /boot/grub/grub.cfg ]; then
	  if gui_yesno "GRUB2 does not appear to be configured.
Automatically install GRUB2 now?"; then
	    create_boot_menu
	    if ! grub_install; then
	      gui_message "There was an error while installing GRUB2."
	    fi
	  fi
	fi

	while

	gui_menu grub 'GRUB2 Boot Loader Setup' \
		"Root device ... $rootdev" "" \
		"Boot device ... $bootdev" "" \
		"Crypt device .. $cryptdev" "" \
		"Grub device ... $grubdev" "" \
		"Inst device ... $instdev" "" \
		'' '' \
		'(Re-)Create boot menu with installed kernels' 'create_boot_menu' \
		"(Re-)Install GRUB2 in boot record ($instdev)" 'grub_install' \
		'' '' \
		"Edit /boot/grub/grub.cfg (Boot Menu)" \
			"gui_edit 'GRUB2 Boot Menu' /boot/grub/grub.cfg"
    do : ; done
}
