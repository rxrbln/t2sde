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
destination=
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
	-*)
	    # split combined args, like -m755
	    for a in `echo $1 | sed '/^-[^-]/ {s/^-//; s/\([^0-9-]\)/ -\1/g}'`; do
		case "$a" in
		-g|-m|-o|-S|--group|--mode|--owner|--suffix)
			newcommand="$newcommand $a $2"
			shift
			;;
		-s|--strip)
			if [[ $command != *install ]]; then
				newcommand="$newcommand $a"
			fi
			;;
		-t)
			: # skip -t for now, as we generate target filenames
			;;
		-*)
			newcommand="$newcommand $a"
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
