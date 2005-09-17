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
				actions="$actions 'runsvctrl $name u (up)'   '$COMMANDDIR/runsvctrl u $dir; sleep 1'"
				actions="$actions 'runsvctrl $name d (down)' '$COMMANDDIR/runsvctrl d $dir; sleep 1'"
				actions="$actions 'runsvctrl $name h (hup)'  '$COMMANDDIR/runsvctrl h $dir; sleep 1'"
			fi
		done
		eval "gui_menu runit_sc_menu '$service -> $location' $actions"
		errno=$?
	done
}

main() {
	local errno=0 dir= service=
	local stats= logstats=
	while [ $errno -eq 0 ]; do
		local installed=
		for dir in $SERVICEDIR/*; do
			service=${dir##*/}
			stats=$( $COMMANDDIR/runsvstat $dir/ 2> /dev/null | cut -d' ' -f2,5- )
			logstats=$( $COMMANDDIR/runsvstat $dir/log/ 2> /dev/null | cut -d' ' -f2,5- )
			installed="$installed '$service [$stats]${logstats:+ log/ [$logstats]}' 'runit_svctrl_menu $dir'"
		done

        	eval "gui_menu runit 'Simple $SERVICEDIR Manager' $installed"
		errno=$?
	done
}
