#!/bin/sh

SYSCONFDIR=/etc
SERVICEDIR=/service
COMMANDDIR=/command

declare -a runit_installed
declare -a runit_available

runit_audit() {
	local entry= available= count=

	entry=0
	while read service; do
		runit_available[$entry*3+0]="${service##*/}" # service name
		runit_available[$entry*3+1]="$service" # service's real location
		runit_available[$entry*3+2]= # installed
		(( entry++ ))
	done < <( find $SYSCONFDIR -type f -name run | sort | sed -e '/\/log\/run$/d;' -e 's,/run$,,g' )
	entry=0
	(( count=${#runit_available[@]}/3 ))
	while read service; do
		runit_installed[$entry*3+0]="${service##*/}" # service name
		runit_installed[$entry*3+1]="$( readlink -f "$service" )" # real location
		runit_installed[$entry*3+2]=
		available=0
		while [ $available -lt $count ]; do
			if [ ${runit_available[$available*3+1]} = ${runit_installed[$entry*3+1]} ]; then
				runit_available[$available*3+2]=$entry
				runit_installed[$entry*3+2]=$available
				break
			fi
			(( available++ ))
		done
		(( entry++ ))
	done < <( find $SERVICEDIR -maxdepth 1 -type l | sort )
}

# u|d|o|p|c|h|a|i|q|1|2|t|k|x|e
runit_svc() {
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

runit_install() {
	local entry="$1" count= 
	(( count=${#runit_installed[@]}/3 ))
	runit_installed[$count*3+0]="${runit_available[$entry*3+0]}"
	runit_installed[$count*3+1]="${runit_available[$entry*3+1]}"
	runit_installed[$count*3+2]=$entry
	runit_available[$entry*3+2]=$count
	ln -snf "${runit_available[$entry*3+1]}" $SERVICEDIR/"${runit_available[$entry*3+0]}"
}

main() {
	local errno=0
	local entry= count=

	runit_audit
	while [ $errno -eq 0 ]; do
		local available= installed=
		local text= action=
		local i= stats=
		declare -a stats
		(( count=${#runit_installed[@]}/3 )); entry=0
		while [ $entry -lt $count ]; do
			text="${runit_installed[$entry*3+0]}"
			action="runit_svc $SERVICEDIR/${runit_installed[$entry*3+0]} ${runit_installed[$entry*3+1]}"
			stats[0]=; stats[1]=; i=0
			while read stats[i++]; do :; done < <( \
				$COMMANDDIR/runsvstat \
				"${runit_installed[$entry*3+1]}" \
				"${runit_installed[$entry*3+1]}"/log 2> /dev/null | \
				sed -n -e 's,^.*: \([^(]*\)\( (.*) \)\?\([^)]*\)$,\1 \3,p' )
			[ "${stats[0]}" ] && text="$text [${stats[0]}]" || text="$text [ERROR]"
			[ "${stats[1]}" ] && text="$text log: [${stats[1]}]"
			[ "${runit_installed[$entry*3+2]}" ] || text="$text [FOREIGN]"
			installed="$installed '$text' '$action'"
			(( entry++ ))
		done
		(( count=${#runit_available[@]}/3 )); entry=0
		while [ $entry -lt $count ]; do
			if [ -z "${runit_available[$entry*3+2]}" ]; then
				text="${runit_available[$entry*3+0]} (${runit_available[$entry*3+1]})"
				if [ -e "$SERVICEDIR/${runit_available[$entry*3+0]}" ]; then
					text="$text [BLOCKED]"
					action=
				else
					action="runit_install $entry"
				fi
				available="$available '$text' '$action'"
			fi
			(( entry++ ))
		done
		
		eval "gui_menu runit 'Simple $SERVICEDIR Manager' $installed '' '' $available"
		errno=$?
	done
}
