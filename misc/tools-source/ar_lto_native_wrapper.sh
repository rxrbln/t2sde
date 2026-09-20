#!/usr/bin/env bash
# --- T2-COPYRIGHT-BEGIN ---
# t2/misc/tools-source/ar_lto_native_wrapper.sh
# Copyright (C) 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---
#
set -e

exec_ar() {
	local mypath="${CMD_WRAPPER_MYPATH:-$(dirname "$0")}"
	PATH="${PATH//$mypath:/}"
	PATH="${PATH//:$mypath/}"
	export PATH
	export AR_LTO_NATIVE_WRAPPER_BYPASS=1
	exec "$(basename "$0")" "$@"
}

is_lto_object() {
	file -b "$1" 2>/dev/null | grep -Eqi 'LLVM.*bitcode|LTO' && return 0
	readelf -S "$1" 2>/dev/null | grep -Eq '\.(gnu|llvm)\.lto' && return 0
	objdump -h "$1" 2>/dev/null | grep -Eq '\.(gnu|llvm)\.lto' && return 0
	return 1
}

native_object_for() {
	local src="$1" out="$2" cc

	if file -b "$src" 2>/dev/null | grep -Eqi 'LLVM.*bitcode'; then
		cc="${CLANG:-${archprefix}clang}"
		read -r -a cc_argv <<< "${cc:-clang}"
		CMD_WRAPPER_BYPASS=1 CC_WRAPPER_BYPASS=1 GCC_WRAPPER_BYPASS=1 \
			"${cc_argv[@]}" -x ir -c -o "$out" "$src"
	else
		cc="${CC:-${archprefix}cc}"
		read -r -a cc_argv <<< "$cc"
		CMD_WRAPPER_BYPASS=1 CC_WRAPPER_BYPASS=1 GCC_WRAPPER_BYPASS=1 \
			"${cc_argv[@]}" -flto -flinker-output=nolto-rel -r -nostdlib -o "$out" "$src"
	fi

	if is_lto_object "$out"; then
		echo "ar_lto_native_wrapper: failed to convert $src to a native object" >&2
		file "$src" "$out" >&2 || true
		readelf -S "$out" 2>/dev/null | grep -E '\.(gnu|llvm)\.lto' >&2 || true
		return 1
	fi
}

[ "$SDECFG_LTO" = 1 ] && [ "$AR_LTO_NATIVE_WRAPPER_BYPASS" != 1 ] || exec_ar "$@"

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

argv=("$@")
updates= archive=
for arg in "$@"; do
	[[ "$arg" = *.a ]] && archive=1
	[[ "$arg" != --* && "$arg" =~ ^-?[a-zA-Z]*[rq][a-zA-Z]*$ ]] && updates=1
done
[ "$updates$archive" = 11 ] || exec_ar "$@"

changed=0
for i in "${!argv[@]}"; do
	arg="${argv[$i]}"
	[ -f "$arg" ] && [[ "$arg" = *.o || "$arg" = *.obj ]] && is_lto_object "$arg" || continue
	mkdir -p "$tmpdir/$i"
	out="$tmpdir/$i/$(basename "$arg")"
	native_object_for "$arg" "$out"
	argv[$i]="$out"
	changed=1
done

[ "$changed" = 1 ] || exec_ar "$@"

exec_ar "${argv[@]}"
