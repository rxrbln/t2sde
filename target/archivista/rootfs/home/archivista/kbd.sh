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

layout=`Xdialog --stdout --cancel-label=Other \
        --combobox "Please choose your keyboard layout." 8 38 \
        US French German Italian SwissGerman SwissFrench SwissItalian`

case "$layout" in
	US) layout=us ;;
	French) layout=fr ;;
	German) layout=de ;;
	Italian) layout=it ;;
	SwissGerman) layout=de_CH ;;
	SwissFrench) layout=fr_CH ;;
	SwissItalian) layout=it_CH ;;
	*) layout=other
esac

if [ "$layout" = other ]; then
	layout=""
	until [ "$layout" ]; do
		tlayout=`Xdialog --stdout --inputbox \
		         "Enter your keyboad layout code:
(e.g. es, fr, ...)" 8 38 $tlayout` \
		         || exit
		if setxkbmap "$tlayout"; then
			layout="$tlayout"
		fi
	done
else
	setxkbmap "$layout"
fi

echo $layout > ~/.xkb-layout
