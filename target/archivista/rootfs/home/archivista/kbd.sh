#!/bin/bash

reconfig=0

if [ "$1" = -reconfig ]; then
        reconfig=1
        shift
fi

. /etc/profile


# translation table for human readable vs. X internal
en_table=(US French German Italian Spanish \
          "Swiss German" "Swiss French" "Swiss Italian")

x_table=(us fr de it es de_CH fr_CH it_CH)


cur_layout=${x_table[0]}

# already configured?
if [ -e ~/.xkb-layout ]; then
	cur_layout=`cat ~/.xkb-layout`
	setxkbmap $cur_layout
	[ $reconfig -eq 0 ] && exit
fi

i=0 ; def="--default-no"
while [ "${x_table[i]}" ]; do
	if [ "${x_table[i]}" = "$cur_layout" ]; then
		def=(--default-item "${en_table[i]}")
		break
	fi
	: $(( i++ ))
done

layout="`Xdialog --stdout --cancel-label=Other "${def[@]}" \
         --combobox "Please choose your keyboard layout." 8 38 \
         "${en_table[@]}"`"


i=0
while [ "${en_table[i]}" ]; do
  if [ "${en_table[i]}" = "$layout" ]; then
		layout=${x_table[i]}
		break
	fi
	: $(( i++ ))
done

# other?
until [ "$layout" ]; do
		cur_layout=`Xdialog --stdout --inputbox \
		         "Enter your keyboad layout code:
(e.g. es, fr, ...)" 8 38 $cur_layout` \
		         || exit
		if setxkbmap "$cur_layout"; then
			layout="$cur_layout"
		fi
done

setxkbmap "$layout"
echo $layout > ~/.xkb-layout
