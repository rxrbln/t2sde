#!/bin/sh

root=

usage() {
	cat <<EOT
usage: $0 [-root <root>] [<pkg>]+
EOT
}

getdeps() {
	if [ -f package/*/$1/$1.cache ]; then
		grep -e "^\[DEP\]" package/*/$1/$1.cache | cut -d' ' -f2- | tr '\n' ' '
	else
		echo "unknown"
	fi
}
getprio() {
	local prio=
	if [ -f package/*/$1/$1.desc ]; then
		prio=`sed -n -e "s,^\[P\] . .* \(.*\),\1,p" package/*/$1/$1.desc`
	fi

	[ -n "$prio" ] && echo "$prio" || echo "---.---"
}
pkginstalled() {
	[ -f $root/var/adm/packages/$1 ]
}

digdeps() {
	local deep="$1" pkg="$2" prefix="$3"
	local cache="$4" banner= dep=

	[ $deep -eq 0 ] && return 0
	(( deep-- ))

	banner="$pkg($( getprio $pkg ))"

	if pkginstalled $pkg; then
		banner="$banner+"
	else
		banner="$banner-"
	fi

	echo -e "$prefix$banner"
	for dep in $( getdeps $pkg ); do
		if [ "$dep" == "unknown" ]; then
			echo -e "$prefix$banner\tNODEPS"
		elif [ -z "$(echo "$cache" | grep ":$dep:" )" ]; then
			digdeps $deep $dep "$prefix$banner\t" "$cache$pkg:"
		fi
	done
}

while [ $# -ne 0 ]; do
	case "$1" in
		-root)	root=$2
			shift ;;
		-*)	echo "ERROR: Option $1 is not recognized."
			usage; exit 1	;;
		*)
			break;
	esac
	shift
done

for pkg; do
	if [ -f package/*/$pkg/$pkg.desc ]; then
		digdeps 2 $pkg '' ':'
	else
		echo "ERROR: '$pkg' not found!" 1>&2
	fi
done
