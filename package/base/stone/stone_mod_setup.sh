# --- T2-COPYRIGHT-BEGIN ---
# t2/package/*/stone/stone_mod_setup.sh
# Copyright (C) 2004 - 2025 The T2 SDE Project
# Copyright (C) 1998 - 2003 ROCK Linux Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---
#
# This module should only be executed once directly after the installation

get_dm_dev() {
	local dev="$1"
	local devnode=$(stat -c "%t:%T" $dev)
	for d in /dev/dm-*; do
		[ "$(stat -c "%t:%T" "$d")" = "$devnode" ] && echo $d && return
	done
	echo $dev
}

get_dm_type() {
	local dev="$1"
	dev="${dev##*/}"
	[ -e /sys/block/$dev/dm/uuid ] && cat /sys/block/$dev/dm/uuid
}

get_dm_slave() {
	local dev="$1"

	# if device-mapper, get slave backing device
	if [[ "$dev" = *mapper* ]]; then
		local dev2=$(get_dm_dev $dev)
		# encrypted?
		if [[ "$(get_dm_type $dev2)" = CRYPT* ]]; then
			dev2=$(cd /sys/block/${dev2##*/}/slaves/; ls)
			[ "$dev2" ] && echo /dev/$dev2
		fi
	fi
	echo $dev
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
	echo $dev
}

make_fstab() {
	local tmp1=`mktemp` tmp2=`mktemp`

	# currently active swaps
	sed '1d; s/ .*/ none swap defaults 0 0/' /proc/swaps > $tmp2

	# copy defaults and fallbacks
	sed 's/  */ /g' /etc/fstab >> $tmp2

	# currently mounted filesystems
	sed -e "s/ nfs [^ ]\+/ nfs rw/;s/ rw,/ /; s/ rw / defaults /" /etc/mtab >> $tmp2

	# sort resulting entries and grab the last (e.g. non-default) one
	cut -f2 -d' ' < $tmp2 | sort -u | while read dn; do
		# include all (999) swaps
		[ "$dn" != none ] && n=1 || n=999
		grep " $dn " $tmp2 | tail -n $n |
		while read dev point type residual; do
			dev=$(get_dm_slave $dev)
			dev=$(get_uuid $dev)
			case $type in
			  *tmpfs|swap)
				echo $dev $point $type $residual && continue ;;
			esac
			case $point in
			  /dev*|/proc*|/sys)
				echo $dev $point $type $residual ;;
			  /)
				echo $dev $point $type ${residual%0 0} 0 1 ;;
			  /boot/efi*)
				echo $dev $point $type ro,${residual%0 0} 0 2 ;;
			  *)
				echo $dev $point $type ${residual%0 0} 0 2 ;;
			esac
		done
	done > $tmp1

	cat << EOT > $tmp2
ARGIND == 1 {
    for (c=1; c<=NF; c++) if (ss[c] < length(\$c)) ss[c]=length(\$c);
}
ARGIND == 2 {
    for (c=1; c<NF; c++) printf "%-*s",ss[c]+2,\$c;
    printf "%s\n",\$NF;
}
EOT
	gawk -f $tmp2 $tmp1 $tmp1 > /etc/fstab

	while read a b c d e f; do
		printf "%-60s %s\n" "$(
			printf "%-50s %s" "$(
				printf "%-40s %s" "$(
					printf "%-25s %s" "$a" "$b"
				)" $c
			)" "$d"
		)" "$e $f"
	done < /etc/fstab | tr ' ' '\240' > $tmp1

	gui_message $'Auto-created /etc/fstab file:\n\n'"$(< $tmp1)"
	rm -f $tmp1 $tmp2
}

set_passwd() {
	if [ "$SETUPG" = dialog ]; then
		local pw1=$(gui_dialog --nocancel --passwordbox "Set $1 password:" 8 70)
		local pw2=$(gui_dialog --nocancel --passwordbox "Confirm $1 password:" 8 70)
		if [ "$pw1" -a "$pw1" = "$pw2" ]; then
			echo "$1:$pw1" | chpasswd
			return $?
		else
			gui_message "Passwords do not match."
			return 1
		fi
	else
		passwd $1
		return $?
	fi
}

create_user() {
	gui_input "Create first user account named:" "user" name
	if [ "$name" ]; then
		if useradd -G audio,input,users,video "$name"; then
			while ! set_passwd "$name"; do :; done
		fi
	fi
}

main() {
	type -p ldconfig && ldconfig

	export gui_nocancel=1
	make_fstab
	$STONE general set_keymap
	while ! set_passwd root; do :; done
	unset gui_nocancel

	create_user

	# run the stone modules that registered itself for the first SETUP pass
	while read -u 200 a b c cmd; do
		$STONE $cmd
	done 200< <( grep -h '^# \[SETUP\] [0-9][0-9] ' \
	          $SETUPD/mod_*.sh | sort)

	cron.run

	# run the postinstall scripts right here
	for x in /etc/postinstall.d/*; do
		[ -f $x ] || continue
		echo "Running $x"
		$x
	done

	exec $STONE
}
