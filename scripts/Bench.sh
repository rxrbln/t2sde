#!/bin/bash
# --- T2-COPYRIGHT-BEGIN ---
# t2/scripts/Bench.sh
# Copyright (C) 2025 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

# Sysinfo and Performance Index collecting.
# Copyright (C) 2022-2023 René Rebe, ExactCODE GmbH; Germany.

set -e
#set -x

fmt_time() {
  [[ "$1" -le 0 ]] && return

  local i=$1 s= u=
  s=`printf "%02d" $(($i % 60))` i=$(($i / 60)) u=s

  [ $i -gt 0 ] && s=`printf "%02d:$s" $(($i % 60))` i=$(($i / 60)) u=m
  [ $i -gt 0 ] && s=`printf "%02d:$s" $i` u=h

  echo "${s#0}$u"
}

get_build_time() {
  local t=$(sed -n '/Build.*from.* /{ s///; h }; ${x; p}' \
	/var/adm/packages/$1)

  # split
  local h=${t%%:*} s=${t##*:}
  local m=${t%:*}; m=${m#*:}

  # remove leading zeros
  echo $((${h#0} * 3600 + ${m#0} * 60 + ${s#0}))
}

get_pkg_ver() {
  local ver=$(sed -n '/Package Name and Version: /{s///p; q}' /var/adm/packages/$1)
  ver="${ver#* }" # pkg name
  echo ${ver// /-} # any extraver
}

get_cfg_val() {
	local v=$(sed -n "s/.*$1='\(.*\)'/\1/p" config/default/config)
	echo "$v"
}

get_system() {
	local sys=$(cat /sys/class/dmi/id/{sys_vendor,product_name} 2>/dev/null)
	[[ "$sys" = "" || $sys = *O.E.M* ]] &&
		sys=$(cat /sys/class/dmi/id/{board_vendor,board_name} 2>/dev/null)

	[ -z "$sys" ] &&
		sys=$(cat /sys/firmware/devicetree/base/name 2>/dev/null | tr -d '\0')

	[ -z "$sys" ] &&
		sys=$(cat /sys/firmware/devicetree/base/mode 2>/dev/null | tr -d '\0')

	[ -z "$sys" ] &&
		sys=$(sed -n '/machine.*: / {s///; h}; /detected as.*: / {s///; H}; ${x; p}' /proc/cpuinfo)

	[ -z "$sys" ] &&
		sys=$(grep "model" /proc/cpuinfo | head -1 | sed 's/.*: *//')

	sys="${sys//
/ }"

	local cpu=$(grep "cpu[[:space:]]*:" /proc/cpuinfo | head -n 1 | sed 's/.*: *//')

	[ -z "$cpu" ] &&
		cpu=$(grep "model name" /proc/cpuinfo | head -1 | sed 's/.*: *//')

	[ -z "$cpu" ] &&
		cpu=$(grep "model" /proc/cpuinfo | head -1 | sed 's/.*: *//')

	# remove trailing spaces
	echo "${sys%%    *}${cpu:+ - $cpu}"
}

get_signature() {
	declare -A opts
	opts[lazy]=1
	opts[speed]=2

	local opt=$(get_cfg_val SDECFG_OPT)
	opt="-O${opts[$opt]:-$opt}"

	local lto=$(get_cfg_val SDECFG_LTO)
	[ "$lto" = 1 ] && opt="$opt, LTO"

	findmnt / | grep -q " nfs" && opt="$opt, nfsroot"
	local tmpfs=$(get_cfg_val SDECFG_TMPFS_MAX_SIZE)
 	[ "$tmpfs" ] && opt="$opt, tmpfs[$tmpfs]"

	local sig="gcc-$(get_pkg_ver gcc) ($opt)"
	local sys=$(uname -s -r | sed 's/ /-/')

	echo "$sig, $sys"
}

sys=$(get_system)
[ -z "$sys" ] && echo "No system ID" && exit 1

echo "$sys"

#mkdir -p "$sys"
#cat /proc/cpuinfo > "$sys/cpuinfo"
#type -p lspci >/dev/null && lspci > "$sys/lspci"
#type -p lsusb >/dev/null && lsusb > "$sys/lsusb"
#type -p dmidecode >/dev/null && dmidecode > "$sys/dmidecode"

tmp=$(mktemp)
touch --date yesterday $tmp
reftime=$(ls build/default-*/TOOLCHAIN/reftime 2>/dev/null || true)

#if [ -e "$reftime" -a $tmp -nt "$reftime" ]; then
#	echo "Found old build/.../reftime, deleting"
#	rm -vf "$reftime"
#fi

built=
for p in lua lua bash binutils; do
	[ "$p" = lua ] && built= # reset to hide 1st cache warmup
	scripts/Emerge-Pkg -optional-deps=no -f $p
	bt=$(get_build_time $p)
	built="$p $built"

	[ $bt -gt $((15*60)) ] && echo "Build time exeeded limit. Stop." && break
done

echo "$sys"
sig=$(get_signature)

for p in $built; do
	echo "$(fmt_time $(get_build_time $p)) $p-$(get_pkg_ver $p) w/ $sig"
done # | tee -a "$sys/perf.txt"

