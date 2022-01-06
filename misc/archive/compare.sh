#!/bin/sh

verbose=0
quiet=0

ignspace=0
ignprio=0
dopatch=0

source=
targets=
repositories=
packages=

function show_usage() {
	echo "usage: $0 [-q[q]] [-v] [-p [-P] [-S]] <source> <target> [-repository <repo>|<packages>|]"
	echo "usage: $0 [-q[q]] [-v] -3 <source> <target1> <target2> [-repository <repo>|<packages>|]"
	echo
	echo "    -q: don't show packages with the same version"
	echo "   -qq: don't show packages missing or with the same version"
	echo "    -v: show extra info about the packages"
	echo "    -p: show patch to turn \$source into \$target"
	echo "    -P: ignore [P]s of .desc files on patches"
	echo "    -S: ignore spaces on patches" 
}

# TODO: it would be great to port it to "-n <n>" instead of -3
#
while [ $# -gt 0 ]; do
	case "$1" in
		-v)	verbose=1	;;
		-q)	quiet=1		;;
		-qq)	quiet=2		;;
		-p)	dopatch=1	;;
		-P)	ignprio=1	;;
		-S)	ignspace=1	;;

		-3)	source="$2"
			targets="$3 $4"
			shift 3		;;

		-repository) 
			shift
			repositories="$*"; set -- 
			;;
		*)	if [ "$targets" ]; then
				packages="$*"; set --
			elif [ "$source" ]; then
				targets="$1"
			else
				source="$1"
			fi
	esac
	shift
done
			
function remove_header() {
	# thanks you blindcoder :)
	#
	local here=0 count=1
	while read line ; do
		count=$(( ${count} + 1 )) 
		[ "${line//COPYRIGHT-NOTE-END/}" != "${line}" ] && here=${count}
	done < $1
	tail -n +${here} $1
}
function show_nice_diff() {
	local diffopt=
	[ $ignspace -eq 1 ] && diffopt='-EBb'

	diff -u $diffopt "$1" "$2" | sed \
		-e 's,^--- .*,--- old/package/'"${3##*/package/}," \
		-e 's,^[\+][\+][\+] .*,+++ new/package/'"${3##*/package/},"
}

function diff_package() {
	local source="$1"
	local target="$2"
	local x= y=

	# files on source
	for x in $source/*; do
		if [ -d "$x/" ]; then
			diff_package $x $target/${x##*/}
		elif [[ "$x" = *.cache ]]; then
			continue
		else
			remove_header $x > $$.source
			if [ -f $target/${x##*/} ]; then
				remove_header $target/${x##*/} > $$.target

				if [[ "$x" = *.desc ]]; then
					y=$( grep -e "^\[P\]" $x )
					[ "$y" -a $ignprio -eq 1 ] && sed -i -e "s,^\[P\] .*,$y," $$.target
				fi

				show_nice_diff $$.source $$.target $x
				rm $$.target
			else
				show_nice_diff $$.source /dev/null $x
			fi
			rm $$.source
		fi
	done
	# files only on target
	for x in $target/*; do
		if [ -d $x/ ]; then
			[ ! -d $source/${x#$target/} ] && diff_package $source/${x#$target/} $x
		elif [[ "$x" = *.cache ]]; then
			continue
		else
			if [ ! -f $source/${x#$target/} ]; then
				remove_header $x > $$.target
				show_nice_diff /dev/null $$.target $source/${x#$target/}
				rm $$.target
			fi
		fi
	done
}

# grabdata confdir field
function grabdata() {
	local confdir=$1
	local pkg=$2
	local field=$3
	local output=

	case "$field" in
		version)	output=$( grabdata_desc $confdir/$pkg.desc $field ) ;;
		*)		output=$( grabdata_cache $confdir/$pkg.cache $field ) ;;
	esac
	if [ -z "${output// /}" ]; then
		echo "UNKNOWN"
	else
		echo "$output"
	fi
}
function grabdata_desc() {
	local output=
	if [ -f "$1" ]; then
		case "$2" in
			version)	output=$( grep -e "^\[V\]" $1 | cut -d' ' -f2- )	;;
		esac
	fi
	echo "$output"
}
function grabdata_cache() {
	local output=
	if [ -f "$1" ]; then
		case "$2" in
			status)	if grep -q -e "^\[.-ERROR\]" $1; then
					output=BROKEN
				else
					output=BUILT
				fi	;;
			size)	output=$( grep -e "^\[SIZE\]" $1 | cut -d' ' -f2- )	;;
		esac
	fi
	echo "$output"
}
function compare_package() {
	local pkg=${1##*/}
	local source=$1
	local target= x= missing=0

	local info=
	local srcver= srcstatus= srcsize=
	local tgtver= tgtstatus= tgtsize=

	shift;

	srcver=$( grabdata $source $pkg version )
	srcstatus=$( grabdata $source $pkg status )
	srcsize=$( grabdata $source $pkg size )
	tgtver=
	tgtstatus=
	tgtsize=

	for x; do
		target=$( echo $x/package/*/$pkg | head -n 1 )
		if [ -d "$target" ]; then
			tgtver="$tgtver:$( grabdata $target $pkg version )"
			tgtstatus="$tgtstatus:$( grabdata $target $pkg status )"
			tgtsize="$tgtsize:$( grabdata $target $pkg size )"
		else
			tgtver="$tgtver:MISSING"
			tgtstatus="$tgtstatus:MISSING"
			tgtsize="$tgtsize:MISSING"
			missing=1
		fi
	done
	
	tgtver="${tgtver#:}"
	tgtstatus="${tgtstatus#:}"
	tgtsize="${tgtsize#:}"

	equalver=1 equalstatus=1
	IFS=':' ; for x in $tgtver; do
		[ "$x" != "$srcver" ] && equalver=0
	done
	IFS=':' ; for x in $tgtstatus; do
		[ "$x" != "$srcstatus" ] && equalstatus=0
	done

	if [ $equalver -eq 1 ]; then
		version=$srcver
	else
		version="$srcver -> $tgtver"
	fi
	
	if [ $equalstatus -eq 1 ]; then
		status="$srcstatus"
	else
		status="$srcstatus -> $tgtstatus"
	fi
	
	if [ $verbose -eq 0 ]; then
		info="($version)"
	else
		info="($version) ($status) ($srcsize -> $tgtsize)"
	fi

	if [ $missing -eq 1 ]; then
		if [ $quiet -le 1 ]; then
			echo "N $pkg $info" 1>&2
			[ $dopatch -eq 1 ] && diff_package $source $target
		fi
	elif [ $equalver -eq 1 ]; then
		if [ $quiet -eq 0 ]; then
			echo "E $pkg $info" 1>&2
			[ $dopatch -eq 1 ] && diff_package $source $target
		fi
	else
		echo "U $pkg $info" 1>&2
		[ $dopatch -eq 1 ] && diff_package $source $target
	fi
}

if [ -z "$source" -o -z "$targets" ]; then
	show_usage; exit 1
fi

allexist=1
for x in $source $targets; do
	[ ! -d "$x/" ] && allexist=0; break
done

if [ $allexist -eq 1 ]; then
	echo -e "from: $source\nto..: $targets" 1>&2

	if [ "$repositories" ]; then
		for repo in $repositories; do
			for x in $source/package/$repo/*; do
				[ -d "$x" ] && ( compare_package $x $targets )
			done
		done
	elif [ "$packages" ]; then
		for pkg in $packages; do
			x=$( echo $source/package/*/$pkg | head -n 1 )
			[ -d "$x" ] && compare_package $x $targets
		done
	else
		for repo in $source/package/*; do
			echo "repository: ${repo##*/}" 1>&2
			for x in $repo/*; do
				[ -d "$x" ] && compare_package $x $targets
			done
		done
	fi
else
	show_usage
	exit 1
fi

