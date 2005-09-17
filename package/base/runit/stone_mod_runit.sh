#!/bin/sh

SYSCONFDIR=/etc
SERVICEDIR=/service
COMMANDDIR=/command

# u|d|o|p|c|h|a|i|q|1|2|t|k|x|e
runit_svctrl_menu() {
	local dir= actions= service=$1 stats=
	actions="'location: $(readlink -f $service)' ''"
	for dir in $1/ $1/log/; do
		if [ -d $dir ]; then
			actions="$actions '' '' \
				'service: $dir' '' \
				'  stats: $( $COMMANDDIR/runsvstat $dir/ 2> /dev/null | cut -d' ' -f2- )' ''"
		fi
	done
	while eval "gui_menu runit_sc_menu '$service' $actions"; do :; done || true
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
