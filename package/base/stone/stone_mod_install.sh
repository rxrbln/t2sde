# --- T2-COPYRIGHT-BEGIN ---
# t2/package/*/stone/stone_mod_install.sh
# Copyright (C) 2004 - 2025 The T2 SDE Project
# Copyright (C) 1998 - 2003 ROCK Linux Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

# TODO:
# - check error, esp. of cryptsetup and lvm commands and display red alert on error
# - avoid all direct user input, so the installer works in GUI variants

# detect platform once
platform=$(uname -m)
platform2=$(grep '\(platform\|type\)' /proc/cpuinfo) platform2=${platform2##*: }
[ -e /sys/firmware/efi ] && platform="$platform-efi" ||
case $platform in
	alpha)
		;;
	arm*|ia64|riscv*)
		platform=
		;;
	parisc*)
		;;
	mips*)
		;;
	ppc*)
		# TODO: prep, ps3, opal, ...
		case "$platform2" in
		    CHRP|PowerMac|PS3)
				platform="$platform-$platform2" ;;
		    *)		platform= ;;
		esac
		;;
	sparc*)
		platform="$platform-$platform2"
		grep -q gpt /sys/firmware/devicetree/base/packages/disk-label/supported-labels 2>/dev/null &&
			platform="$platform-gpt"
		;;
	i?86|x86_64)
		platform="$platform-pc"
		# TODO: better test for 528m and 2gb BIOS limits
		atadrv="$(cat /sys/bus/scsi/devices/host0/scsi_host/host0/proc_name 2>/dev/null)"
		[ "$atadrv" = pata_legacy -o "$atadrv" = pata_isapnp ] &&
			platform="$platform-legacy"
		unset atadrv
		;;
	*)
		platform=
		;;
esac

mapper2lvm() {
	local x="${1//--/	}"
	x="${x/-//}" x="${x//	/-}"
	echo "$x"
}

part_mounted_action() {
	if gui_yesno "Do you want to unmount the filesystem on $1?"
	then umount /dev/$1; fi
}

part_activepv_action() {
	if gui_yesno "Do you want to remove physical LVM $1 from volume group $2?"
	then vgreduce $2 /dev/$1; fi
}

part_swap_action() {
	if gui_yesno "Do you want to deactivate the swap space on $1?"
	then swapoff /dev/$1; fi
}

part_mount() {
	local dev=$1 compress="$2" dir="$3"

	if [ -z "$dir" ]; then
		dir="/ /boot /home /srv /var"
		[ -d /sys/firmware/efi ] && dir="${dir/boot/boot/efi}"
		local d
		for d in $dir; do
			grep -q " /mnt${d%/} " /proc/mounts || break
		done

		gui_input "Mount device $dev on directory
(for example ${dir// /, }, ...)" "${d:-/}" dir
	fi

	if [ "$dir" ]; then
		dir="$(echo $dir | sed 's,^/*,,; s,/*$,,')"
		# check if at least a rootfs / is already mounted
		if [ -z "$dir" ] || grep -q " /mnt " /proc/mounts
		then
			mkdir -p /mnt/$dir
			[ "$compress" ] && mount -o "$compress" $dev /mnt/$dir 2>/dev/null ||
				mount $dev /mnt/$dir
		else
			gui_message "Please mount a root filesystem first."
		fi
	fi
}

part_mkswap() {
	local dev=$1
	mkswap -L swap $dev; swapon $dev
}

part_mkfs() {
	local dev=$1 fs=$2 mnt=$3 label= opts=
	cmd="gui_menu part_mkfs 'Create filesystem on $dev'"

	case "$mnt" in
	    /)	label="root" ;;
	    /home)	label="home" ;;
	    /boot)	label="swap" ;;
	    /boot/efi)	label="efi" ;;
	esac

	maybe_add() {
	  local l=
	  [ "$label" -a "$5" ] && l="$5 $label"
	  [ "$1" = "$fs" ] && opts="$3 $4 $l"
	  if type -p $3 >/dev/null; then
		cmd="$cmd '$1 ($2 filesystem)' \
		'type -p wipefs >/dev/null && wipefs -a $dev; $3 $4 $l $dev'"
	  fi
	}

	maybe_add btrfs	'Better, b-tree, CoW journaling' 'mkfs.btrfs' '-f' '-L'
	maybe_add bcachefs	'Bcache CoW file system' 'mkfs.bcachefs' '-f' '-l'
	maybe_add ext4	'journaling, extents'	'mkfs.ext4' '' '-L'
	maybe_add ext3	'journaling'		'mkfs.ext3' '' '-L'
	maybe_add ext2	'non-journaling'	'mkfs.ext2' '' '-L'
	maybe_add jfs	'IBM journaling'	'mkfs.jfs' '' '-L'
	maybe_add reiserfs 'journaling'		'mkfs.reiserfs' '' '-l'
	maybe_add xfs	'SGI journaling'	'mkfs.xfs' '-f' '-L'
	[ "$fs" = xfs0 ] &&
	maybe_add xfs0	'SGI journaling v0'	'mkfs.xfs' '-f -n ftype=0 -m crc=0' '-L'
	maybe_add fat	'File Allocation Table'	'mkfs.fat' '' '-n'

	[ "$fs" -a "$fs" != any ] && cmd="$opts $dev"

	if eval "$cmd"; then
		part_mount $dev "compress=zstd" $mnt
	fi
}

part_decrypt() {
	local dev=$1
	local dir=$2

	if [ ! "$dir" ]; then
	    dir="root home swap"
	    local d
	    for d in $dir; do
		[ -e /dev/mapper/$dir ] || break
	    done
	    gui_input "Mount device $dev on directory
(for example ${dir// /, }, ...)" "${d:-/}" dir
	fi

	if [ "$dir" ]; then
		# TBC
		dir="$(echo $dir | sed 's,^/*,,; s,/*$,,')"
		cryptsetup luksOpen --disable-locks $dev $dir
	fi
}

part_crypt() {
	local dev=$1; shift
	local mnt=$1; shift

	# --pbkdf=pbkdf2
	cryptsetup luksFormat --disable-locks "$@" $dev || return

	part_decrypt $dev $mnt
}

vg_add_pv() {
	vg="$2"
	[ "$vg" ] || gui_input "Add physical volume $1 to logical volume group:" "vg0" vg
	if [ "$vg" ]; then
	    if vgs $vg 2>/dev/null; then
		vgextend $vg $1
	    else
		vgcreate $vg $1
	    fi
	fi
}

part_pvcreate() {
	local dev=$1
	pvcreate $dev
	vg_add_pv $dev $2
}

part_unmounted_action() {
	local dev=$1 stype=$2

	type=$(blkid --match-tag TYPE /dev/$dev)
	type=${type#*\"}; type=${type%\"*}
	[ "$type" = swsuspend ] && type="swap"

	local cmd="gui_menu part $dev"
	local active=1
	[[ "$stype" = "lv" && "$(lvs -o active --noheadings /dev/$dev)" != *active ]] && active=

	if [ "$active" ]; then
	  [ "$type" -a "$type" != "swap" -a "$type" != "crypto_LUKS" ] &&
		cmd="$cmd \"Mount existing $type filesystem\" \"part_mount /dev/$dev\""
	  if [ "$type" = "crypto_LUKS" ]; then
		cmd="$cmd \"Activate encrypted LUKS\" \"part_decrypt /dev/$dev\""
		#cmd="$cmd \"Deactivate encrypted LUKS\" \"part_decrypt /dev/$dev\""
	  fi

	  [ "$type" = "swap" ] &&
		cmd="$cmd \"Activate existing swap space\" \"swapon /dev/$dev\""

	  cmd="$cmd \"Create filesystem\" \"part_mkfs /dev/$dev\""
	  cmd="$cmd \"Create swap space\" \"part_mkswap /dev/$dev\""
	  cmd="$cmd \"Encrypt using LUKS cryptsetup\" \"part_crypt /dev/$dev '' --type luks1\""
	  cmd="$cmd \"Encrypt using LUKS2 cryptsetup\" \"part_crypt /dev/$dev\""

	  [ "$stype" != "lv" ] &&
		cmd="$cmd \"Create physical LVM volume\" \"part_pvcreate /dev/$dev\""
	fi

	if [ "$stype" = "lv" ]; then
		[ "$active" ] &&
		cmd="$cmd 'Deactivate logical LVM volume' 'lvchange -an $dev'" ||
		cmd="$cmd 'Activate logical LVM volume' 'lvchange -ay $dev'"
		cmd="$cmd \"Rename logical LVM volume\" \"lvm_rename $dev lv\""
		cmd="$cmd \"Remove logical LVM volume\" \"lvremove $dev\""
	elif [ "$type" = "LVM2_member" ]; then
		cmd="$cmd 'Add physical LVM volume to volume group' 'vg_add_pv /dev/$dev'"
		cmd="$cmd 'Remove physical LVM volume' 'pvremove /dev/$dev'"
	fi

	eval $cmd
}

part_add() {
	local dev
	[ ! -L /dev/$1 ] && dev=/dev/$1 || dev=$(readlink /dev/$1)

	local action="unmounted" location="currently not mounted"
	if grep -q "^$dev " /proc/swaps; then
		action=swap location="swap  <no mount point>"
	elif grep -q "^$dev " /proc/mounts; then
		action=mounted
		location="`grep "^$dev " /proc/mounts | cut -d ' ' -f 2 |
			  sed "s,^/mnt,," `"
		[ "$location" ] || location="/"
	fi

	# save volume information
	disktype $dev > /tmp/stone-install 2>/dev/null
	type="`grep /tmp/stone-install -v -e '^  ' -e '^Block device' \
	       -e '^Partition' -e '^---' |
	       sed -e 's/[,(].*//' -e '/^$/d' -e 's/ $//' | tail -n 1`"
	size="`grep 'Block device, size' /tmp/stone-install |
	       sed 's/.* size \(.*\) (.*/\1/'`"
	if [ -z "$type" ]; then
		type=$(blkid --match-tag TYPE $dev)
		type=${type#*\"}; type=${type%\"*}
	fi

	# active LVM pv?
	if [[ "$type" = *LVM2*volume* ]]; then
		local vg=`pvs --noheadings -o vgname $dev`
		vg="${vg##* }"
		[ "$vg" ] && action=activepv && location="$vg" && set "$1" "$vg"
	fi

	dev=${1#*/}; dev=${dev#mapper/}
	cmd="$cmd '`printf "%-6s %-24s %-10s" $dev "$location" "$size"` ${type//_/ }' 'part_${action}_action $1 $2'"
}

function join() {
	local IFS="$1"; shift
	echo "$*"
}

disk_partition() {
	local dev=$1
	local typ=$2

	# sizes in MB
	local size=$(($(blockdev --getsz $dev) / 2 / 1024))
	si=0
	for p in $dev[0-9]*; do
		[ -e $p ] || continue
		size=$((size - $(blockdev --getsz $p) / 2 / 1024))
		# determine last used partition, too
		local i=${p#$dev}
		[ $i -gt $si ] && si=$i
	done

	local cmd="gui_menu part 'Partition $dev bootable for this platform?'"

	cmd="$cmd 'Erasing all data' 'si=0'"
	# TODO: check patform is efi and type is GPT?
	[ $si -gt 0 -a $size -gt 4096 ] &&
		cmd="$cmd 'Adding partitions in free space' si=$si"

	eval $cmd || return

	# if re-partition: reset size to all
	[ "$si" = 0 ] && size=$(($(blockdev --getsz $dev) / 2 / 1024))
	local swap=$((size / 20)) # TODO: better
	local boot=512

	local fdisk="sfdisk -W always"
	local script=()
	local postscript=()
	local fs=()
	local any=any

	[ $swap -gt 1024 ] && swap=1024
	# dedicated swap partition or lvm?
	local _swap=$swap
	[[ "$typ" = *lvm* ]] && _swap=0 && any=lvm

	case $platform in
	    alpha)
		fdisk="parted -f"
		fs+=("${dev}2 $any /")
		fs+=("${dev}1 ext3 /boot")
		script+=("mklabel bsd
y
mkpart 2048s ${boot}m
mkpart ${boot}m $(($size - $boot - $_swap))m")

		[ $_swap != 0 ] &&
		    script+=("mkpart $(($size - $boot - $_swap))m 100%") fs+=("${dev}3 swap")
		;;
	    *-efi)
		script+=("label:gpt")
		script+=("size=128m, type=uefi")
		script+=("size=$((size - 128 - _swap))m, type=linux")
		fs+=("${dev}$((si + 2)) $any /")
		fs+=("${dev}$((si + 1)) fat /boot/efi")

		[ $_swap != 0 ] &&
		    script+=("type=swap") fs+=("${dev}$((si + 3)) swap")
		;;
	    parisc*)
		fs+=("${dev}3 $any /")
		fs+=("${dev}2 ext3 /boot")

		script+=("label:dos
size=32m, type=f0
size=${boot}m, type=83
size=$((size - _swap))m, type=83")
		[ $_swap != 0 ] &&
		    script+=("type=82") fs+=("${dev}4 swap")
		;;
	    mips64) # TODO: match Sgi only
		local volhdr=8 i=1

		# the rounding is way off, so -20m at times rounding safety :-/
		script+=("label:sgi")

		[ $boot != 0 ] && script+=("start=$((volhdr))m, size=$((boot))m, type=83") && : $((i++))
		script+=("start=$((volhdr + boot))m, size=$((size - boot - _swap - volhdr - 10))m, type=83")
		fs+=("${dev}$((i++)) $any /")
		[ $boot != 0 ] && fs+=("${dev}1 xfs0 /boot")

		[ $_swap != 0 ] &&
		    script+=("start=$((volhdr + size - _swap - volhdr))m, size=$((_swap - 10))m, type=82") &&
		    fs+=("${dev}$((i++)) swap")

		script+=("9: size=${volhdr}m, type=0
11: type=6")
		;;
	    ppc*CHRP)
		# TODO: typ, luks, lvm, ...
		fs+=("${dev}2 $any /")
		script+=("label:dos
size=4m, type=41
size=$((size - _swap))m, type=83")

		[ $_swap != 0 ] &&
		    script+=("type=82") fs+=("${dev}3 swap")
		;;
	    ppc*PowerMac)
		fdisk=mac-fdisk
		fs+=("${dev}3 $any /")
		script+=("i

b 2p
c 3p $((size - _swap))m linux")

		[ $_swap != 0 ] &&
		    script+=("c 4p 4p swap") fs+=("${dev}4 swap")

		script+=("w
y
q
")
		;;
	    sparc*-gpt)
		script+=("label:gpt")
		script+=("size=2m, type=biosboot")
		script+=("size=$((size - _swap))m, type=linux")
		fs+=("${dev}$((si + 1)) $any /")

		[ $_swap != 0 ] &&
		    script+=("type=swap") fs+=("${dev}$((si + 2)) swap")
		;;
	    sparc*)
		# TODO: silo vs grub2 have different requirements
		# TODO: support sun4v-gpt
		script+=("label:sun
size=$((boot))m, type=83
type=82
start=0, type=W")

		# sfdisk has a "hard" time creating more than 2 parts w/ whole-disk
		local i=2
		if [ $_swap != 0 ]; then
		    postscript+=("sfdisk --delete ${dev} 2")
		    postscript+=("echo 'size=${_swap}m, type=82' | sfdisk -N 2 ${dev}")
		    postscript+=("echo 'type=83' | sfdisk -N 4 ${dev}")
		    i=4
		    fs+=("${dev}2 swap")
		fi

		fs+=("${dev}$i $any /")
		fs+=("${dev}1 ext3 /boot")
		;;
	    *)
		script+=("label:dos")
		local i=1

		[[ "$platform" != ppc*PS3 && "$platform" != *86*-legacy ]] &&
		    boot=0

		[ $boot != 0 ] && script+=("size=$((boot))m, type=83") && ((i++))
		[ $_swap != 0 ] && fs+=("${dev}$((i++)) swap") script+=("size=${_swap}m, type=82")

		script+=("type=83") fs+=("${dev}$((i++)) $any /")

		[ $boot != 0 ] && fs+=("${dev}1 ext3 /boot")
		;;
	esac

	# re-partition or append?
	if [ "$si" = 0 ]; then
		# partition
		wipefs --all $dev
		dd if=/dev/zero of=$dev seek=1 count=1 # mostly for Apple PowerPac parts
	else
		fdisk="$fdisk -a"
		script=("${script[@]:1}") # removed 1st "label:*"
	fi

	join $'\n' "${script[@]}" | $fdisk $dev

	# postscript fixup, due less than stellar sfdisk
	for cmd in "${postscript[@]}"; do
	    eval "$cmd"
	done

	# create fs
	for f in "${fs[@]}"; do
	    set $f
	    local d=$1
	    local fs=$2
	    local mnt=$3

	    # fix device partitions separated w/ p
	    [[ $dev = *[0-9] ]] && d=${dev}p${d#$dev}

	    if [[ "$typ" = *luks* && ("$mnt" = / || "$fs" = swap) ]]; then
		local name=root
		[ "$fs" = swap ] && name=swap
		part_crypt $d $name
		d=/dev/mapper/$name
	    fi

	    case $fs in
		lvm)	part_pvcreate $d vg0
			lv_create vg0 linear ${swap}m swap
			lv_create vg0 linear 100%FREE root
			part_mkswap /dev/vg0/swap
			part_mkfs /dev/vg0/root any /
			;;
		swap)	part_mkswap $d
			;;
		*)	part_mkfs $d $fs $mnt
			;;
	    esac
	done
}

disk_action() {
	if grep -q "^/dev/$1 " /proc/swaps /proc/mounts; then
		gui_message "Partitions from $1 are currently in use, so you
can't modify this partition table."
		return
	fi

	local cmd="gui_menu disk 'Edit partition table of $1'"

	cmd="$cmd \"Automatically partition${platform:+ bootable for this platform ($platform)}:\" ''"
	cmd="$cmd \"Classic partitions\" \"disk_partition /dev/$1\""
	if [ "$platform" ]; then
	    case "$platform" in
	    #*efi|*CHRP|*86*-pc)
	    *)
		type -p cryptsetup >/dev/null &&
		cmd="$cmd \"Encrypted partitions\" \"disk_partition /dev/$1 luks\""
		type -p lvm >/dev/null &&
		cmd="$cmd \"Logical Volumes\" \"disk_partition /dev/$1 lvm\""
		type -p cryptsetup >/dev/null && type -p lvm >/dev/null &&
		cmd="$cmd \"Encrypted Logical Volumes\" \"disk_partition /dev/$1 luks+lvm\""
		;;
	    esac
	fi
	cmd="$cmd '' ''"

	cmd="$cmd \"Edit partition table:\" ''"
	for x in cfdisk fdisk pdisk mac-fdisk parted; do
		type -p $x >/dev/null &&
		  cmd="$cmd \"$x\" \"$x /dev/$1\""
	done

	eval $cmd
}

lvm_rename() {
	local dev=$1
	echo $dev $type
	gui_input "Rename $dev:" "${dev#*/}" name

	if [ "$2" = vg ]; then
		vgrename $dev $name
	else
		lvrename $dev $name
	fi
}


lv_create() {
	local dev=$1 type=$2
	size=$3 name=$4
	stripes="--config allocation/raid_stripe_all_devices=1"

	if [ ! "$size" ]; then
		#size=$(vgdisplay $dev | grep Free | sed 's,.*/,,; s, <,,; s/ //g ')
		size="100%FREE"
		gui_input "Logical volume size:" "$size" size
	fi

	if [ "$type" = "striped" ]; then
		stripes=$(vgs --noheadings -o pv_count $dev)
		stripes=${stripes:+-i $stripes}
	fi

	if [ "$size" ]; then
		[ "$name" ] || gui_input "Logical volume name:" "" name
		[[ "$size" = *%* ]] && size="-l $size" || size="-L $size"
		lvcreate $size --type $type $stripes $dev ${name:+-n $name}
	fi
}

vg_action() {
	local cmd="gui_menu vg 'Volume Group $1'"

	cmd="$cmd 'Create Linear logical volume' 'lv_create $1 linear'"
	cmd="$cmd 'Create Striped logical volume' 'lv_create $1 striped'"
	cmd="$cmd 'Create RAID 0 logical volume' 'lv_create $1 raid0'"
	cmd="$cmd 'Create RAID 1 logical volume' 'lv_create $1 raid1'"
	cmd="$cmd 'Create RAID 5 logical volume' 'lv_create $1 raid5'"
	cmd="$cmd 'Create RAID 6 logical volume' 'lv_create $1 raid6'"
	cmd="$cmd 'Create RAID 10 logical volume' 'lv_create $1 raid10'"
	cmd="$cmd '' ''"
	cmd="$cmd 'Activate all volumes in group' 'vgchange -ay $1'"
	cmd="$cmd 'Deactivate all volumes in group' 'vgchange -an $1'"
	cmd="$cmd 'Rename volume group' 'lvm_rename $1 vg'"
	cmd="$cmd 'Remove volume group' 'vgremove $1'"
	cmd="$cmd 'Display low-level information' 'gui_cmd \"display $1\" vgdisplay $1'"

	eval $cmd
}

disk_add() {
	local x found=0

	local vendor model # read w/ whitespaces stripped:
	read vendor < <(cat /sys/block/$1/device/vendor 2>/dev/null)
	read model < <(cat /sys/block/$1/device/model 2>/dev/null)
	read vendor <<< "$vendor $model"

	cmd="$cmd 'Edit partition table of $1${vendor:+ ($vendor)}:' 'disk_action $1'"

	local lbs=$(< /sys/block/$1/queue/logical_block_size)
	local pbs=$(< /sys/block/$1/queue/physical_block_size)

	if [ "$lbs" = 512 -a "$pbs" != 4096 ] && type -p nvme >/dev/null; then
		nvme id-ns -H /dev/$1 2>/dev/null | grep -q "LBA Format.*4096" &&
			pbs=4096
	fi

	[ "$lbs" = 512 -a "$pbs" = 4096 ] &&
		cmd="$cmd 'Warning: likely not formatted AF/4Kn for best performance!' ''"
	[ "$lbs" != 512 -a "$lbs" != 4096 ] &&
		cmd="$cmd 'Warning: formated w/ unsupported sector size ($lbs)!' ''"

	# TODO: maybe better /sys/block/$1/$1* ?
	for x in $(cd /dev; ls $1[0-9p]* 2> /dev/null); do
		part_add $x
		found=1
	done
	[ $found = 0 ] && cmd="$cmd 'Partition table is empty.' ''"
	cmd="$cmd '' ''"
}

vg_add() {
	local x= found=0

	cmd="$cmd 'Logical volumes of $1:' 'vg_action $1'"

	[ -x /sbin/lvs ] &&
	for x in $(lvs --noheadings -o lv_path $1 2> /dev/null); do
		x=${x#/dev/}
		part_add $x lv
		found=1

		# remove from raw device-mapper list
		x=$(readlink /dev/$x)
		volumes="${volumes/ ${x#/dev/} /}"
	done
	if [ $found = 0 ]; then
		cmd="$cmd 'No logical volumes.' ''"
	fi

	cmd="$cmd '' ''"
}

main() {
	$STONE general set_keymap

	local install_now=0
	while [ $install_now = 0 ]; do
		cmd="gui_menu install 'Storage setup: Partitions and mount-points

Modify your storage layout: create file-systems, swap-space, encrypt and mount them. You can also use advanced low-level tools on the command line.'"

		local found=0
		volumes=""
		for x in /sys/block/*; do
			[ ! -e $x/device -a ! -e $x/dm ] && continue
			x=${x#/sys/block/}

			# media? udevadm info -q property --name=/dev/...
			[[ "$x" = fd[0-9]* || "$x" = sr[0-9]* ]] && continue

			# LVM Device Mapper?
			if [ -e /sys/block/$x/dm ]; then
				if [ -e /sys/block/$x/dm/name ]; then
					x=$(< /sys/block/$x/dm/name)
					[[ $x = *_rimage* || $x = *_rmeta* ]] && continue
				fi
				volumes="${volumes} mapper/$x "
			else
				disk_add $x
			fi
			found=1
		done

		[ -x /sbin/vgs ] &&
		for x in $(vgs --noheadings -o name 2> /dev/null); do
			vg_add "$x"
			found=1
		done

		# any other remaining device-mapper, e.g. LUKS cryptosetup
		if [ "$volumes" ]; then
			for x in $volumes; do
				part_add $x
			done
			cmd="$cmd '' ''"
		fi

		if [ $found = 0 ]; then
			cmd="$cmd 'No storage found!' ''"
		fi

		cmd="$cmd 'Install the system ...' 'install_now=1'"

		eval "$cmd" || break

		if [ "$install_now" = 1 ] && ! grep -q " /mnt" /proc/mounts; then
			gui_yesno "No storage mounted to /mnt, continue anyway?" ||
				install_now=0
		fi
	done

	if [ "$install_now" -ne 0 ]; then
		$STONE packages

		mount -v --bind /dev /mnt/dev
		cat > /mnt/tmp/stone_postinst.sh << EOT
#!/bin/bash
mount -v /proc
mount -v /sys
. /etc/profile
stone setup
umount -v /dev
umount -v /proc
umount -v /sys
EOT
		chmod +x /mnt/tmp/stone_postinst.sh
		rm -f /mnt/etc/mtab
		# TODO: tr mapper2lvm
		sed -n '/ \/mnt[/ ]/s,/mnt/\?,/,p' /proc/mounts |
		# convert mapper to 1st class lvm names
		while read dev x; do
		    if [[ "$dev" = *mapper* ]]; then
			local y=/dev/$(mapper2lvm ${dev#/dev/mapper/})
			[ -e $y ] && dev=$y
		    fi
		    echo "$dev $x"
		done > /mnt/etc/mtab

		cd /mnt; chroot . ./tmp/stone_postinst.sh
		rm -fv ./tmp/stone_postinst.sh

		kexec=$(type -p kexec)

		if gui_yesno "Do you want to un-mount the filesystems and reboot${kexec:+ (via kexec)} now?"
		then
			# try to re-boot via kexec, if available
			if [ "$kexec" ]; then
			    cmdline=$(< /proc/cmdline)
			    # extract root=
			    if [ -e /mnt/boot/grub/grub.cfg ]; then
				root=$(sed -n "/.*\(root=.*\)/{ s//\1/p; q}" /mnt/boot/grub/grub.cfg)
			    elif [ -e /mnt/boot/etc/kboot.conf ]; then
				root=$(sed -n "/.*\(root=[^\"']*\).*/{ s//\1/p; q}" /mnt/boot/etc/kboot.conf)
			    else
				root=$(grep ' / ' /mnt/etc/fstab | tail -n 1 | sed 's, .*,,')
				root=${root:+root=$root}
			    fi
			    # determine kernel image, from cmdline or installed files
			    kernel="BOOT_IMAGE= $cmdline" kernel=${kernel##*BOOT_IMAGE=} kernel=${kernel%% *}
			    kernel="${kernel//*\//}"
			    if [ "$kernel" ]; then
				kernel="boot/$kernel"
			    else
				# any vmlinu*
			        kernel="$(cd /mnt; echo boot/vmlinu[xz]-*)"
			        kernel="${kernel##* }" # last, compressed if both
			    fi
			    kexec -l /mnt/$kernel --initrd="/mnt/${kernel/vmlinu?/initrd}" \
				  --command-line="$cmdline $root"
			fi
			shutdown -r now
		else
			echo
			echo "You might want to umount all filesystems now and reboot"
			echo "the system now using the commands:"
			echo
			echo "	shutdown -r now"
			echo
			echo "Or by executing 'shutdown -r now' which will run the above commands."
			echo
		fi
	fi
}
