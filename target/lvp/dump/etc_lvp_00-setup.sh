#!/bin/bash

for x in `cat /proc/cmdline` ; do
	if [[ $x = *keymap* ]] ; then
		keymap=`find /usr/share/kbd/keymaps -name "${x##*=}.map*" 2>/dev/null`
		if [ -f "${keymap}" ] ; then
			cd ${keymap%/*}
			loadkeys ${keymap##*/}
		fi
	fi
done
