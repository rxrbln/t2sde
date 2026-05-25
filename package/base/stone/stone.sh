#!/bin/bash
# --- T2-COPYRIGHT-BEGIN ---
# t2/package/*/stone/stone.sh
# Copyright (C) 2004 - 2026 The T2 SDE Project
# Copyright (C) 1998 - 2003 ROCK Linux Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

export SETUPD="${SETUPD:-/etc/stone.d}"
if type -p dialog > /dev/null; then
	export SETUPG="${SETUPG:-dialog}"
else
	export SETUPG="${SETUPG:-text}"
fi
export STONE="`type -p $0`"

if [ "$1" = "-text"   ]; then SETUPG="text"   ; shift; fi
if [ "$1" = "-dialog" ]; then SETUPG="dialog" ; shift; fi
if [ "$1" = "-x11"    ]; then SETUPG="x11"    ; shift; fi

. ${SETUPD}/gui_${SETUPG}.sh

if [ "$1" -a -f "${SETUPD}/mod_$1.sh" ]
then
	. ${SETUPD}/mod_$1.sh ; shift
	if [ -z "$*" ]; then
		main
	else
		eval "$*"
	fi
elif [ "$#" = 0 -a -f ${SETUPD}/default.sh ]
then
	. ${SETUPD}/default.sh
elif [ "$#" = 0 ]
then
	while
		command="gui_menu main 'Main Menu - Select the Subsystem you want to configure'"
		while read a b c cmd name ; do
			x="'" cmd="${cmd//,/ }"
			command="$command '${name//$x/$x\\$x$x}'"
			command="$command '$STONE ${cmd//$x/$x\\$x$x}'"
		done < <( grep -h '^# \[MAIN\] [0-9][0-9] ' \
						$SETUPD/mod_*.sh | sort )
		eval "$command"
	do : ; done
else
	echo
	echo "STONE - Setup Tool ONE - System Configuration"
	echo
	echo "Usage: $0 [ -text | -dialog | -x11 ] [ module [ command ] ]"
	echo
fi
