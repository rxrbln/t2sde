#!/bin/sh

if [ "$1" == "-v" ]; then
	VERBOSE=1; shift
else
	VERBOSE=
fi
LOGSDIR=$1/var/adm/logs

if [ ! -d $LOGSDIR ]; then
	echo "'${LOGSDIR%var/adm/logs}' is not a valid root."
	exit 1
fi

for repo in package/*; do
	svn st $repo | cut -d'/' -f3 | sort -u | \
	while read pkg; do
		status=
		for file in $( ls -1 $LOGSDIR/[0-9]-${pkg}.{out,err,log} 2> /dev/null ); do
			case $file in
			*.err)	status=2	;;
			*.log)	[ "$status" ] || status=1	;;
			esac
		done
		if [ -z "$status" ]; then
			[ "$VERBOSE" ] && echo "$pkg PENDING"
		elif [ "$status" == 2 ]; then
			echo "$pkg FAILED"
		else
			echo "$pkg OK"
		fi
	done
done
