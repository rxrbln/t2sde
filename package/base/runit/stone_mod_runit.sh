#!/bin/sh

SYSCONFDIR=/etc
SERVICEDIR=/service
COMMANDDIR=/command

# u|d|o|p|c|h|a|i|q|1|2|t|k|x|e
runit_svctrl_menu() {
	local service=$1 errno=0 name= dir=
	local prefix=${service%/*} location=$(readlink -f $service)

	while [ $errno -eq 0 ]; do
		local actions=
		for dir in $service/ $service/log/; do
			if [ -d $dir ]; then
				name=${dir#$prefix/}
				[ "$actions" ] && actions="$actions '' ''"

				actions="$actions 'service: $dir' '' \
					'  stats: $( $COMMANDDIR/runsvstat $dir/ 2> /dev/null | cut -d' ' -f2- )' ''"
				actions="$actions 'runsvctrl u $name (up)'   '$COMMANDDIR/runsvctrl u $dir; sleep 1'"
				actions="$actions 'runsvctrl d $name (down)' '$COMMANDDIR/runsvctrl d $dir; sleep 1'"
				actions="$actions 'runsvctrl h $name (HUP)'  '$COMMANDDIR/runsvctrl h $dir; sleep 1'"
			fi
		done
		eval "gui_menu runit_sc_menu '$service -> $location' $actions"
		errno=$?
	done
}

runit_svstat() {
	local dir= stat=
	local logof= logstat=
	local service=

	$COMMANDDIR/runsvstat $* | sort |
		sed -n -e 's,^\(.*\): \([^(]*\)\( (.*) \)\?\([^)]*\)$,dir="\1" stats="\2 \4",p' |
		while read line; do
			dir= stats=
			eval "$line"

			if [[ $dir = */log ]] ; then
				logof=${dir%/log}
				logstat=${stats}
			else
				service=${dir##*/}
				if [ "$dir" == "$logof" ]; then
					echo "'$service [$stats] log: [$logstat]' 'runit_svctrl_menu $dir'"
				else
					echo "'$service [$stats]' 'runit_svctrl_menu $dir'"
				fi
				logof=
			fi
	done
}

main() {
	while eval "gui_menu runit 'Simple $SERVICEDIR Manager' \
		$( runit_svstat /service/*{,/log} | tr '\n' ' ' )"; do
		:; done
}
