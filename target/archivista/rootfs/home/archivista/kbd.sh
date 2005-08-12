#!/bin/bash

reconfig=0

if [ "$1" = -reconfig ]; then
        reconfig=1
        shift
fi

. /etc/profile

# already configured?
if [ -e ~/.xkb-layout ]; then
	setxkbmap `cat ~/.xkb-layout`
	[ $reconfig -eq 0 ] && exit
fi

layout=`Xdialog --stdout --combobox "Please choose your keyboard layout." 8 38 \
        US German Switzerland other`

case "$layout" in
	US) layout=us ;;
	German) layout=de ;;
	Switzerland) layout=de_CH ;;
	*) layout=other
esac

if [ "$layout" = other ]; then
	layout=""
	until [ "$layout" ]; do
		tlayout=`Xdialog --stdout --inputbox \
		         "Enter your keyboad layout code:" 8 38 $tlayout`
		if setxkbmap "$tlayout"; then
			layout="$tlayout"
		fi
	done
else
	setxkbmap "$layout"
fi

echo $layout > ~/.xkb-layout
