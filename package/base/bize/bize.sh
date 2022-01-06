#!/bin/sh

bize_usage()
{
	echo "usage: bize -i [-t] [-v] [-f] [-R root] package1.tar.bz2 ..." 1>&2
	echo "       bize -r [-t] [-v] [-f] [-R root] package1 ..." 1>&2
}

bize_remove()
{
	local line base tag md5s="$adm/md5sums/$pkg"

	if [ "$keep" ] ; then
		if [ ! -f "$md5s" ] ; then
			echo "$0: $md5s: no such file, skipping remove" 1>&2
			return
		fi

		(cd "$root/" && md5sum -c "var/adm/md5sums/$pkg" 2> /dev/null) |
		while read line ; do
			base="${line%: *}"
			stat="${line##*: }"
			file="$root/$base"
			if [ -z "$base" -o -z "$stat" ] ; then
				echo "$0: invalid md5sum output '$line'" 1>&2
			elif [ -f "$file" -a ! -L "$file" ] ; then
				if [ "$stat" = OK ] ; then
					$unlink "$file"
				elif [ "$stat" != FAILED ] ; then
					echo "$0: $file: $stat"
				elif [ "$test" ] ; then
					echo "$0: $file: modified, skipping"
				fi
			fi
		done
	fi

	sort -r "$list" | while read tag base ; do
		file="$root/$base"
		if [ "$tag" != "$pkg:" ] ; then
			echo "$0: invalid tag '$tag' in $list" 1>&2
		elif [ -z "$base" ] ; then
			echo "$0: missing file name in $list" 1>&2
		elif [ -L "$file" ] ; then
			$unlink "$file"
		elif [ -d "$file" ] ; then
			$test rmdir $voption "$file"
		elif [ "${base#var/adm/}" != "$base" -a -f "$file" ] ; then
			$unlink "$file"
		elif [ "$keep" -a -f "$file" ] ; then
			[ "$test" ] || echo "$0: $file: modified, skipping"
		else
			$unlink "$file"
		fi
	done
}

bize_install()
{
	if [ ! -f "$arch" ] ; then
		echo "$0: $arch: no such file, skipping install" 1>&2
		return
	fi

	pkg="${arch%.tar.bz2}"
	if [ "$arch" = "$pkg" ] ; then
		echo "$0: $arch: not a .tar.bz2 file" 1>&2
		return
	fi
	pkg="${pkg%-[0-9]*}"
	pkg="${pkg##*/}"

	if [ -z "$pkg" ] ; then
		echo "$0: $arch: missing package name" 1>&2
		return
	fi
	[ "${arch#-}" = "$arch" ] || arch="./$arch"
	
	list="$adm/flists/$pkg"
	if [ -f "$list" ] ; then
		[ "$verbose" ] && echo "updating $pkg ..."
		bize_remove
	else
		[ "$verbose" ] && echo "installing $pkg ..."
	fi

	$test mkdir -p$verbose "$root/"
	if [ "$test" ] ; then
		echo "bzip2 -c -d $arch | tar $taropt -C $root/"
	else
		bzip2 -c -d "$arch" | tar $taropt -C "$root/"
	fi
}

bize_uninstall()
{
	[ "$verbose" ] && echo "removing $pkg"
	list="$adm/flists/$pkg"
	if [ -f "$list" ] ; then
		bize_remove
	else
		echo "$0: $list: no such file, skipping remove" 1>&2
	fi
}

bize_main()
{
	local which=which file arch list="sort rm rmdir mkdir tar bzip2"
	local install remove test verbose voption keep=k root=/ taropt

	while [ "$1" ] ; do
		case "$1" in
			-i) install=1 ;;
			-r) remove=1 ;;
			-t) test=echo ;;
			-f) keep="" ;;
			-v) verbose=v ; voption=-v ;;
			-R) shift ; root="$1" ;;
			-R*) root="${1#-R}" ;;
			--) break ;;
			-*) bize_usage ; return 1 ;;
			*) break;;
		esac
		shift
	done

	if type sh > /dev/null 2>&1 ; then
		which=type
	elif ! which sh > /dev/null ; then
		echo "$0: unable to find 'type' or 'which'" 1>&2
		return 1
	fi

	[ "$keep" ] && list="$list md5sum"
	for file in $list ; do
		if ! $which $file > /dev/null ; then
			echo "$0: unable to find '$file'" 1>&2
			return 1
		fi
	done

	if [ "$install" = "$remove" -o -z "$root" -o -z "$*" ] ; then
		bize_usage
		return 1
	fi

	root="${root%/}"
	[ "${root#-}" = "$root" ] || root="./$root"

	local adm="$root/var/adm" unlink="$test rm -f$verbose" pkg

	if [ "$install" ] ; then
		taropt="xp${verbose}${keep}"
		for arch do
			bize_install
		done
	else
		for pkg do
			bize_uninstall
		done
	fi

	return 0
}

bize_main "$@"
