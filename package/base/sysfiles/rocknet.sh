#!/bin/bash

rocknet_debug=0
rocknet_base="/etc/network"
rocknet_tmp_base="/var/run/rocknet"

[ -d $rocknet_tmp_base ] || mkdir -p $rocknet_tmp_base

unset code_snipplets_idx code_snipplets_dat code_snipplets_counter
declare -a code_snipplets_idx='()'
declare -a code_snipplets_dat='()'
code_snipplets_counter=0

lineno=0
ignore=0
global=1

if [ "$3" != "up" -a "$3" != "down" ]; then
	echo "Usage: $0 { profile | default } { interface | auto } { up | down }"
	exit 1
fi

profile=$1
interface=$2
mode=$3

pmatched=0 # some profile matched ?
imatched=0 # some interface matched ?

#
# addcode mode major-priority minor-priority code1
#
addcode() {
	[ "$mode" != "$1" ] && return
	[ "$ignore" -gt 0 ] && return
	if [ "$1" = "up" ]; then udo="+"; else udo="-"; fi
	code_snipplets_idx[code_snipplets_counter]="`
		printf '%04d.%04d.%04d' $((5000$udo$2)) $((5000$udo$lineno)) \
		$((5000$udo$3))` $code_snipplets_counter"
	code_snipplets_dat[code_snipplets_counter]="$4"
	(( code_snipplets_counter++ ))
}

#
# isfirst unique-id
#
isfirst() {
	[ "$ignore" -gt 0 ] && return 0
	eval "\$isfirst_$1"
	eval "isfirst_$1='return 1'"
	return 0
}

#
# error error-message
#
error() {
	echo "$*"
}

status() {
	echo "$*"
}

#
# register / unregister active interfaces for user input validation
#

register() {
	echo -n "${1}," >> $rocknet_tmp_base/active-interfaces
}

unregister () {
	active_interfaces="`cat $rocknet_tmp_base/active-interfaces 2>/dev/null`"
	active_interfaces="${active_interfaces//${1},/}"
	echo -n "$active_interfaces" > $rocknet_tmp_base/active-interfaces
}

for x in "$rocknet_base"/modules/*.sh; do . "$x"; done

while read cmd para
do
	(( lineno++ ))
	if [ -n "$cmd" ]; then
		cmd="${cmd//-/_}"
		para="$( echo "$para" | sed 's,[\*\?],\\&,g' )"
		if declare -f public_$cmd > /dev/null
		then
			# optimization: Only execute commands when they are
			# inside an unignored interface section ...
			if [ $cmd = "interface" ] ; then
				public_$cmd $para
				global=0
			elif [ $ignore -eq 0 -o $global -gt 0 ] ; then
				public_$cmd $para
			fi
		else
			error "Unknown statement in config file: $cmd"
		fi
	fi
done < <( sed 's,\(^\|[ \t]\)#.*$,,' < "$rocknet_base"/config )

while read id1 id2; do
	if [ "$rocknet_debug" = 1 ]; then
		echo ">> $id1 -> $id2: ${code_snipplets_dat[id2]}"
	fi
	eval "${code_snipplets_dat[id2]}"
done < <(
	for x in "${code_snipplets_idx[@]}"; do echo "$x"
	done | sort
)

[ "$pmatched" = 0 ] && \
	error "Unknown profile: '$profile'"
[ "$pmatched" = 1 -a "$imatched" = 0 ] && \
	error "Unknown interface for profile: '$interface'"

