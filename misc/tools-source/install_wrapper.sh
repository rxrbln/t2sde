#!/bin/bash

PATH="${PATH/:$INSTALL_WRAPPER_MYPATH:/:}"
PATH="${PATH#$INSTALL_WRAPPER_MYPATH:}"
PATH="${PATH%:$INSTALL_WRAPPER_MYPATH}"

filter="${INSTALL_WRAPPER_FILTER:+|} $INSTALL_WRAPPER_FILTER"

if [ "$INSTALL_WRAPPER_NOLOOP" = 1 ]; then
	echo "--"
	echo "Found loop in install_wrapper: $0 $*" >&2
	echo "INSTALL_WRAPPER_MYPATH=$INSTALL_WRAPPER_MYPATH"
	echo "PATH=$PATH"
	echo "--"
	exit 1
fi
export INSTALL_WRAPPER_NOLOOP=1

echo "" >> "${INSTALL_WRAPPER_LOGFILE:-.install_wrapper_log}"
echo "$PWD:" >> "${INSTALL_WRAPPER_LOGFILE:-.install_wrapper_log}"
echo "* ${INSTALL_WRAPPER_FILTER:-No Filter.}" >> "${INSTALL_WRAPPER_LOGFILE:-.install_wrapper_log}"
echo "- $( basename $0 ) $*" >> "${INSTALL_WRAPPER_LOGFILE:-.install_wrapper_log}"

command="$( basename $0 )"
destination=""
declare -a sources
newcommand="$command"
sources_counter=0
error=0

while [ $# -gt 0 ]; do
	case "$1" in
		-g|-m|-o|-S)
			newcommand="$newcommand $1 $2"
			shift 1
			;;
		-*)
			newcommand="$newcommand $1"
			;;
		*)
			if [ -n "$destination" ]; then
				sources[sources_counter++]="$destination"
			fi
			destination="$1"
			;;
	esac
	shift 1
done

destination="$( eval "echo \"$destination\" $filter" )"

if [ $sources_counter -eq 0 ]; then
	echo "+ $newcommand $destination" \
		>> "${INSTALL_WRAPPER_LOGFILE:-.install_wrapper_log}"
	$newcommand "$destination" || error=$?
elif [ -d "$destination" ]; then
	for source in "${sources[@]}"; do
		echo "+ $newcommand $source $( eval \
			"echo \"$destination/$(basename $source)\" $filter" )" \
				>> "${INSTALL_WRAPPER_LOGFILE:-.install_wrapper_log}"
		$newcommand "$source" "$( eval \
			"echo \"$destination/$(basename $source)\" $filter" )" || error=$?
	done
else
	echo "+ $newcommand ${sources[*]} $destination" \
		>> "${INSTALL_WRAPPER_LOGFILE:-.install_wrapper_log}"
	$newcommand "${sources[@]}" "$destination" || error=$?
fi

echo "===> Returncode: $error" >> "${INSTALL_WRAPPER_LOGFILE:-.install_wrapper_log}"

exit $error

