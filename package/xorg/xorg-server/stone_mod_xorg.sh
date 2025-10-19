# --- T2-COPYRIGHT-BEGIN ---
# t2/package/*/xorg-server/stone_mod_xorg.sh
# Copyright (C) 2004 - 2025 The T2 SDE Project
# Copyright (C) 1998 - 2004 ROCK Linux Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---
#
# [MAIN] 50 xorg X11 Configuration

set_wm() {
	echo "export WINDOWMANAGER=\"$*\"" > /etc/profile.d/windowmanager
}

set_xdm() {
	echo "export XDM=\"$*\"" > /etc/conf/xdm
}

main() {
	while
		WINDOWMANAGER=
		if [ -f /etc/profile.d/windowmanager ]; then
			. /etc/profile.d/windowmanager
		fi

		XDM=""
		if [ -f /etc/conf/xdm ]; then
			. /etc/conf/xdm
		fi

		cmd="gui_menu x 'X11 Configuration Menu'
		'Run XcfgT2 (the T2 LiveCD auto configuration)' 'gui_cmd XcfgT2 xcfgt2'

		'Run X -configure (automated config)'
			'gui_cmd Xorg Xorg -configure ; mv -v /root/xorg.conf.new /etc/X11/xorg.conf'"

		cmd="$cmd '' ''"

		for x in /usr/share/registry/xdm/*; do
		  if [ -f $x ]; then
			. $x # TODO: parse file!

			[ "$XDM" = "$exec" ] && pre='[*]' || pre='[ ]'

			cmd="$cmd
			    '$pre Use $name in runlevel 5'
			    'set_xdm $exec'"
		  fi
		done

		cmd="$cmd '' ''"

		for x in /usr/share/xsessions/*; do
		  if [ -f $x ]; then
			name=$(sed -n '/^Name=/{ s///p; q }' $x)
			exec=$(sed -n '/^Exec=/{ s///p; q }' $x)

			[ "$WINDOWMANAGER" = "$exec" ] && pre='[*]' || pre='[ ]'

			cmd="$cmd
			    '$pre Use $name as default Windowmanager'
			    'set_wm $exec'"
		  fi
		done

		cmd="$cmd '' ''"

		cmd="$cmd
		'Edit/View /etc/X11/xorg.conf'
			'gui_edit xorg.conf /etc/X11/xorg.conf'
		'Edit/View /etc/profile.d/windowmanager'
			'gui_edit WINDOWMANAGER /etc/profile.d/windowmanager'"

		eval $cmd
	do : ; done
}
