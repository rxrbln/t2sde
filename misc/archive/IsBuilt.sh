#!/bin/sh

config=default
if [ "$1" == "-cfg" ]; then
	config="$2"; shift; shift
fi

VERBOSE=
if [ "$1" == "-v" ]; then
	VERBOSE=1; shift
fi

if [ ! -f config/$config/packages ]; then
	echo "ERROR: '$config' is not a valid config"
	exit 1
fi

eval `grep 'ROCKCFG_ID=' config/$config/config 2> /dev/null`
LOGSDIR=build/$ROCKCFG_ID/var/adm/logs
if [ -z "$ROCKCFG_ID" -o ! -d $LOGSDIR ]; then
	echo "ERROR: 'build/$ROCKCFG_ID/' is not a valid build root (sandbox)"
	exit 1
fi

i=1
while read x x x repo pkg x; do
	svnstatus="`svn st package/$repo/$pkg`"
	if [ "$svnstatus" ]; then
		status=
		errlog=
		for file in $( ls -1 $LOGSDIR/[0-9]-${pkg}.{out,err,log} 2> /dev/null ); do
			case $file in
			*.err)	errlog="$errlog$file "; status=2	;;
			*.log)	[ "$status" ] || status=1	;;
			esac
		done
		if [ -z "$status" ]; then
			[ "$VERBOSE" ] && echo "$i package/$repo/$pkg PENDING"
		elif [ "$status" == 2 ]; then
			echo "$i package/$repo/$pkg FAILED $errlog"
		else
			echo "$i package/$repo/$pkg OK"
		fi
		(( i++ ))
	fi
done < config/ref/packages

