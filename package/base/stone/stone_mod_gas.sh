# --- T2-COPYRIGHT-BEGIN ---
# t2/package/*/stone/stone_mod_gas.sh
# Copyright (C) 2004 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

# TODO: remote fget

extract() {
    ver=${ver% *}
    echo "Installing $pkg ($ver) ..."
    $packager -i -R $root $mnt/$iver/pkgs/$pkg-${ver/ /-}.$ext
}

inst() {
    local pkgsel=$1
    local section=0 selected pkg ver

    cat $mnt/$iver/pkgs/packages.db | gunzip -d |
    while read line; do
        if [ "${line}" = $'\004' ]; then
                section=0
                [ $selected = 1 ] && extract
        elif [ "${line}" = $'\027' ]; then
                ((++section))
        else
                # each 1st new section line pkg name
                if [ $section = 0 ]; then
                        pkg=$line
                        selected=0
                else
                        if [[ $section = 1 && "$line" = "[V]"* ]]; then
                                ver=${line#\[V\] }
                        elif [[ $section = 1 && "$line" = "[C]"* ]]; then
                                cat=${line#\[C\] }
                                # TODO: iterate multiple Categories!
                                #echo "$pkg> $cat"

                                selected=1
                                case "$cat" in
                                */kernel*|*/firmware*|*/boot*)
                                        [ $pkgsel = minimal-container ] && selected=0 ;;
                                *base/x11*)
                                        [ $pkgsel = minimal -o $pkgsel = minimal-container ] && selected=0 ;;
                                *base/*)
                                        : ;;
                                *)
                                        [ $pkgsel = all ] || selected=0
                                esac
                        fi
                fi
        fi
    done
}

main() {
	local iver=$1 root=$2 dev=$3 mnt=$4

	if ! [ -f $mnt/$iver/pkgs/packages.db ]; then
		gui_message "gas: package database not accessible."
		return
	fi

	if ! [ -d $root ]; then
		gui_message "gas: target directory not accessible."
		return
	fi

	if [ $root = "${root#/}" ]; then
		gui_message "gas: target directory not absolute."
		return
	fi

	local packager=mine ext=tar.*
	if type -p bize >/dev/null && ! type -p mine >/dev/null; then
		packager=bize
	fi

	cmd="gui_menu pkgsel 'Package set to install'"
	cmd="$cmd 'Minimal base' 'inst minimal'"
	cmd="$cmd 'Minimal X11' 'inst minimal-xorg'"
	cmd="$cmd 'All available' 'inst all'"

	eval "$cmd"
}
