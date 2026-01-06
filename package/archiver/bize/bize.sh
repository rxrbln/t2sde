#!/bin/bash
# --- T2-COPYRIGHT-BEGIN ---
# t2/package/*/bize/bize.sh
# Copyright (C) 2004 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

bize_usage() {
	echo "usage: bize -i [-t] [-v] [-f] [-R root] package1.tar.* ..." >&2
	echo "       bize -r [-t] [-v] [-f] [-R root] package1 ..." >&2
}

bize_remove() {
	local line base tag md5s="$adm/md5sums/$pkg"

	if [ "$keep" ]; then
		if [ ! -f "$md5s" ]; then
			echo "$0: $md5s: no such file, skipping remove" >&2
			return
		fi

		(cd "$root/" && md5sum -c "var/adm/md5sums/$pkg" 2> /dev/null) |
		while read line; do
			base="${line%: *}"
			stat="${line##*: }"
			file="$root/$base"
			if [ -z "$base" -o -z "$stat" ]; then
				echo "$0: invalid md5sum output '$line'" >&2
			elif [ -f "$file" -a ! -L "$file" ]; then
				if [ "$stat" = OK ]; then
					$unlink "$file"
				elif [ "$stat" != FAILED ]; then
					echo "$0: $file: $stat"
				elif [ "$test" ]; then
					echo "$0: $file: modified, skipping"
				fi
			fi
		done
	fi

	sort -r "$list" | while read tag base; do
		file="$root/$base"
		if [ "$tag" != "$pkg:" ]; then
			echo "$0: invalid tag '$tag' in $list" >&2
		elif [ -z "$base" ]; then
			echo "$0: missing file name in $list" >&2
		elif [ -L "$file" ]; then
			$unlink "$file"
		elif [ -d "$file" ]; then
			$test rmdir $voption "$file"
		elif [ "${base#var/adm/}" != "$base" -a -f "$file" ]; then
			$unlink "$file"
		elif [ "$keep" -a -f "$file" ]; then
			[ "$test" ] || echo "$0: $file: modified, skipping"
		else
			$unlink "$file"
		fi
	done
}

bize_install() {
	if [ ! -f "$arch" ]; then
		echo "$0: $arch: no such file, skipping install" >&2
		return
	fi

	pkg="${arch%.tar.*}"
	if [ "$arch" = "$pkg" ]; then
		echo "$0: $arch: not a .tar file?" >&2
		return
	fi
	pkg="${pkg%-[0-9]*}"
	pkg="${pkg##*/}"

	if [ -z "$pkg" ]; then
		echo "$0: $arch: missing package name" >&2
		return
	fi
	
	list="$adm/flists/$pkg"
	if [ -f "$list" ]; then
		[ "$verbose" ] && echo "updating $pkg ..."
		bize_remove
	else
		[ "$verbose" ] && echo "installing $pkg ..."
	fi

	$test mkdir -p$verbose "$root/"
	if [ "$test" ]; then
		echo "zstd -d < $arch | tar $taropt -C $root/"
	else
		zstd -d < "$arch" | tar $taropt -C "$root/"
	fi
}

bize_uninstall() {
	[ "$verbose" ] && echo "removing $pkg"
	list="$adm/flists/$pkg"
	if [ -f "$list" ]; then
		bize_remove
	else
		echo "$0: $list: no such file, skipping remove" >&2
	fi
}

bize_bundle() {
	[ -z "${root}" ] && root='/'

	[ ! -f "${root}var/adm/flists/$pkg" ] && \
		echo "$0: $pkg: no such package" >&2

	local ver=$(head -1 ${root}/var/adm/packages/$pkg | cut -d' ' -f6)
	local compressor="zstd -T0 -19"
	local ext="zst"

	echo "Creating a binary package of $pkg-$ver"
	(cd ${root}
		(grep ' var/adm' ${root}var/adm/flists/$pkg;
		 grep -v ' var/adm' ${root}var/adm/flists/$pkg) | cut -d' ' -f2 \
		| tar -cf- --no-recursion --files-from=- \
		| $compressor
	) > ./$pkg-$ver.tar.$ext
}

bize_query() {
	local files
	if [ -z "$pkg" ]; then
		files=$(ls -r $adm/*/*)
	else
		if [ ! -f "$adm/flists/$pkg" ]; then
			echo "$0: No such package: $pkg" >&2
			return
		fi
		files=$(ls $adm/*/$pkg)
	fi
	case "$query_type" in
		q) awk -F': ' 'FNR==1 { print $2 }' $(echo "$files" | awk '$0 ~ /packages/') ;;
		p) cat $(awk '$0 ~ /packages/' <<< "$files") ;;
		l) cat $(awk '$0 ~ /flists/' <<< "$files") ;;
		m) cat $(awk '$0 ~ /md5sums/' <<< "$files") ;;
		d) cat $(awk '$0 ~ /dependencies/' <<< "$files") ;;
		y) md5sum --check --quiet $(awk '$0 ~ /md5sum/' <<< "$files") ;;
	esac
}

bize_main() {
	local which=which file arch list="sort rm rmdir mkdir tar awk cat ls"
	local install remove bundle test verbose voption keep=k root=/ taropt query

	while [ "$1" ]; do
		case "$1" in
			-i) install=1 ;;
			-r) remove=1 ;;
			-t) test=echo ;;
			-f) keep="" ;;
			-v) verbose=v voption=-v ;;
			-R) shift ; root="$1" ;;
			-R*) root="${1#-R}" ;;
			-b) bundle=1; remove=0 ;; # quick hack for the if install = remove
			-q|-p|-l|-m|-d|-y) query=1; query_type="${1#-}" ;;
			--) break ;;
			-*) bize_usage ; return 1 ;;
			*) break ;;
		esac
		shift
	done

	if type sh > /dev/null 2>&1; then
		which=type
	elif ! which sh > /dev/null; then
		echo "$0: unable to find 'type' or 'which'" >&2
		return 1
	fi

	[ "$keep" ] && list="$list md5sum"
	for file in $list; do
		if ! $which $file > /dev/null; then
			echo "$0: unable to find '$file'" >&2
			return 1
		fi
	done

	if [ "$install$remove$query" != "1" -o -z "$root" ]; then
		bize_usage
		return 1
	fi
	if [ -z "$*" -a -z "$query" ]; then
		bize_usage
		return 1
	fi

	root="${root%/}"
	[ "${root#-}" = "$root" ] || root="./$root"

	local adm="$root/var/adm" unlink="$test rm -f$verbose" pkg

	if [ "$install" ]; then
		taropt="xp${verbose}${keep}"
		for arch do
			bize_install
		done
	elif [ "$query" ]; then
		if [ -z "$*" ]; then
			bize_query
		fi
		for pkg do
			bize_query
		done
	elif [ "$bundle" ]; then
		for pkg do
			bize_bundle
		done
	else
		for pkg do
			bize_uninstall
		done
	fi

	return 0
}

bize_main "$@"
