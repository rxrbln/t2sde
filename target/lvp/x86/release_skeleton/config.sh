#!/bin/bash

. scripts/functions

[ -e .config ] && . .config

quit=0
while [ "${quit}" == "0" ] ; do
	menu_init
	. scripts/configuration
	clear
	display
	read -p "Enter your choice> " choice
	case "${choice}" in
		q)
			quit=1
			;;
		s)
			save
			;;
		l)
			load
			;;
		c)
			save
			scripts/create_lvp
			;;
		x)
			scripts/cleanup
			;;
		i)
			scripts/create-iso
			;;
		*)
			get ${choice}
			;;
	esac
done

