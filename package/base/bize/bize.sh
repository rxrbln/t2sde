#!/bin/sh

bize_usage()
{
	echo "usage: bize -i [-t] [-v] [-f] [-R root] package1.tar.bz2 ..." 1>&2
	echo "       bize -r [-t] [-v] [-f] [-R root] package1 ..." 1>&2
}

bize_remove()
{
	local tag base sum md5s="$adm/md5sums/$pkg"

	if [ "$keep" ] ; then
		if [ ! -f "$md5s" ] ; then
			echo "$0: $md5s: no such file, skipping remove" 1>&2
			return
		fi

		while read tag base ; do
			file="$root/$base"
			if [ -z "$base" ] ; then
				echo "$0: invalid line '$tag' in $md5s" 1>&2
			elif [ -f "$file" -a ! -L "$file" ] ; then
				sum="`md5sum < $file`"
				sum="${sum%  -}"
				if [ "$tag" = "$sum" ] ; then
					$unlink "$file"
				elif [ "$test" ] ; then
					echo "$0: $file: modified, skipping"
				fi
			fi
		done < $md5s
	fi

	sort -r -- "$list" | while read tag base ; do
		file="$root/$base"
		if [ "$tag" != "$pkg:" ] ; then
			echo "$0: invalid tag '$tag' in $list" 1>&2
		elif [ -z "$base" ] ; then
			echo "$0: missing file name in $list" 1>&2
		elif [ "$base" != "${base#var/adm/}" ] ; then
			continue
		elif [ -L "$file" ] ; then
			$unlink "$file"
		elif [ -d "$file" ] ; then
			$test rmdir $voption -- "$file"
		elif [ "$keep" -a -f "$file" ] ; then
			[ "$test" ] || echo "$0: $file: modified, skipping"
		else
			$unlink "$file"
		fi
	done

	for base in cksums dependencies descs flists logs md5sums packages ; do
		$unlink "$adm/$base/$pkg"
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
	pkg="${pkg##*/}"
	pkg="${pkg%-[0-9]*}"

	if [ -z "$pkg" ] ; then
		echo "$0: $arch: missing package name" 1>&2
		return
	fi
	
	list="$adm/flists/$pkg"
	if [ -f "$list" ] ; then
		[ "$verbose" ] && echo "updating $pkg ..."
		bize_remove
	else
		[ "$verbose" ] && echo "installing $pkg ..."
	fi

	$test mkdir -p$verbose -- "$root/"
	if [ "$test" ] ; then
		echo "bzip2 -c -d -- $arch | tar $taropt -C $root/"
	else
		bzip2 -c -d -- "$arch" | tar $taropt -C "$root/"
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
	local install remove test verbose voption keep=1 root=/ taropt

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

	if type which > /dev/null 2>&1 ; then
		which=type
	elif ! which which > /dev/null 2>&1 ; then
		echo "$0: unable to find 'type' or 'which'" 1>&2
		return 1
	fi

	[ "$keep" ] && list="md5sum $list"
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

	root=${root%/}

	local adm="$root/var/adm" unlink="$test rm -f$verbose --" pkg

	if [ "$install" ] ; then
		taropt="x${verbose}"
		[ "$keep" ] && taropt="${taropt}k"
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
unset bize_usage bize_remove bize_install bize_uninstall bize_main
