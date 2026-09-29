#!/usr/bin/env bash
# --- T2-COPYRIGHT-BEGIN ---
# t2/misc/tools-source/install_wrapper.sh
# Copyright (C) 2004 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

PATH="${PATH/:$INSTALL_WRAPPER_MYPATH:/:}"
PATH="${PATH#$INSTALL_WRAPPER_MYPATH:}"
PATH="${PATH%:$INSTALL_WRAPPER_MYPATH}"

if [ "$INSTALL_WRAPPER_NOLOOP" = 1 ]; then
	echo "--"
	echo "Found loop in install_wrapper: $0 $*" >&2
	echo "INSTALL_WRAPPER_MYPATH=$INSTALL_WRAPPER_MYPATH"
	echo "PATH=$PATH"
	echo "--"
	exit 1
fi
export INSTALL_WRAPPER_NOLOOP=1

logfile="${INSTALL_WRAPPER_LOGFILE:-/dev/null}"
[ -z "${logfile##*/*}" -a ! -d "${logfile%/*}" ] && logfile=/dev/null

command="${0##*/}"
destination= tdir=
declare -a sources
newcommand="$command"
sources_counter=0
error=0

echo ""						>> $logfile
echo "$PWD:"					>> $logfile
echo "* ${INSTALL_WRAPPER_FILTER:-No Filter.}"	>> $logfile
echo "- $command $*"				>> $logfile

if [ "${*/--target-directory//}" != "$*" ]; then
	echo "= $command $*" >> $logfile
	$command "$@"; exit $?
fi

while [ $# -gt 0 ]; do
    # split combined args
    case "$1" in
	--group|--mode|--owner|--suffix)
		newcommand="$newcommand $1 $2"
		shift
		;;
	--strip)
		[[ $command != *install ]] && newcommand="$newcommand $1"
		;;
	--*)
		newcommand="$newcommand $1"
		;;
	-?*)
	    # split combined args, like -Dm755 or -oroot
	    opts="${1#-}"
	    while [ -n "$opts" ]; do
		a="${opts:0:1}" opts="${opts:1}"
		case "$a" in
		g|m|o|S|t)
			val="$opts" opts=
			[ -z "$val" ] && val="$2" && shift
			# target directory, we generate the target filenames
			if [ "$a" = t ]; then
				tdir="$val"
			else
				newcommand="$newcommand -$a $val"
			fi
			;;
		s)
			[[ $command != *install ]] && newcommand="$newcommand -$a"
			;;
		*)
			newcommand="$newcommand -$a"
			;;
		esac
	    done
	    ;;

	*)
		if [ -n "$destination" ]; then
			sources[sources_counter++]="$destination"
		fi
		destination="$1"
		;;
    esac
    shift
done

if [ -n "$tdir" ]; then
	[ -n "$destination" ] && sources[sources_counter++]="$destination"
	destination="$tdir"
	[[ " $newcommand " = *" -D "* ]] && mkdir -p "$destination"
fi

[ -z "${destination##/*}" ] || destination="$PWD/$destination"

if [ "$INSTALL_WRAPPER_FILTER" != "" ]; then
	# normalize multiple / path separators to allow filters to just match
	destination="$(eval "echo \"$destination\" | tr -s '/' | $INSTALL_WRAPPER_FILTER" )"
fi

if [ -z "$destination" -o $sources_counter -eq 0 ]; then
	echo "+ $newcommand $destination" >> $logfile
	$newcommand "$destination" || error=$?
elif [ -d "$destination" ]; then
	for source in "${sources[@]}"; do
		thisdest="${destination}"
		[ ! -d "${source//\/\///}" ] && thisdest="$thisdest/${source##*/}"
		thisdest="${thisdest//\/\///}"
		[ "$INSTALL_WRAPPER_FILTER" != "" ] &&
			thisdest="$(eval "echo \"$thisdest\" | $INSTALL_WRAPPER_FILTER" )"
		if [ ! -z "$thisdest" ]; then
			echo "+ $newcommand $source $thisdest" >> $logfile
			$newcommand "$source" "$thisdest" || error=$?
		fi
	done
else
	echo "+ $newcommand ${sources[*]} $destination" >> $logfile
	$newcommand "${sources[@]}" "$destination" || error=$?
fi

echo "===> Returncode: $error" >> $logfile
exit $error
