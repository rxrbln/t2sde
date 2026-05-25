# --- T2-COPYRIGHT-BEGIN ---
# t2/package/*/stone/stone_mod_hardware.sh
# Copyright (C) 2004 - 2026 The T2 SDE Project
# Copyright (C) 1998 - 2003 ROCK Linux Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---
#
# [MAIN] 20 hardware Kernel Drivers and Hardware Configuration

store_clock() {
	if [ -f /etc/conf/clock ]; then
		sed -e "s/clock_tz=.*/clock_tz=$clock_tz/" \
		  < /etc/conf/clock > /etc/conf/clock.tmp
		grep -q clock_tz= /etc/conf/clock.tmp || \
		  echo clock_tz=$clock_tz >> /etc/conf/clock.tmp
		mv /etc/conf/clock.tmp /etc/conf/clock
	else
		echo -e "clock_tz=$clock_tz" \
		  > /etc/conf/clock
	fi
}

set_zone() {
	clock_tz=$1
	hwclock --hctosys --$clock_tz
	store_clock
}

set_rtc() {
	store_clock
}

main() {
    while
	clock_tz=utc
	if [ -f /etc/conf/clock ]; then
	    . /etc/conf/clock
	fi

	cmd="gui_menu hw 'Kernel Drivers and Hardware Configuration'"
	
	if [ "$clock_tz" = localtime ]; then
	    cmd="$cmd '[*] Use localtime instead of utc' 'set_zone utc'"
	else
	    cmd="$cmd '[ ] Use localtime instead of utc' 'set_zone localtime'"
	    clock_tz=utc
	fi
 
	eval "$cmd"
    do : ; done

    return
}
