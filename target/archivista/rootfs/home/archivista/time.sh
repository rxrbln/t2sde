# 
# based on T2 SDE: package/.../sysfiles/stone_mod_general.sh
# Copyright (C) 2004 - 2005 The T2 SDE Project
# Copyright (C) 1998 - 2003 ROCK Linux Project
# 
#
# Archivista time setup

if [ "$UID" -ne 0 ]; then
        exec gnomesu -t "Setup date and time" \
        -m "Please enter the system password (root user)^\
in order to setup the date and time." -c $0
fi

# PATH and co
. /etc/profile

set_tmzone() {
set -x
	area=$(Xdialog --stdout --no-cancel --combobox "Select one of the
following time areas." 8 38 `grep '^[^#]' /usr/share/zoneinfo/zone.tab |
	       cut -f3 | cut -f1 -d/ | sort -u | tr '\n' ' '`)

	zone=$(Xdialog --stdout --no-cancel --combobox "Select one of the
following time zones." 8 38 `grep "$area/" /usr/share/zoneinfo/zone.tab |
	       cut -f3 | cut -f2 -d/ | sort -u | tr '\n' ' '`)

	echo "$area/$zone"
	ln -sfv ../usr/share/zoneinfo/$area/$zone /etc/localtime
}

set_dtime() {
	dtime="`date '+%m-%d %H:%M %Y'`"
	[ -f /etc/conf/clock ] && . /etc/conf/clock
	[ "$clock_tz" != localtime ] && clock_tz=utc
	newdtime=`Xdialog --stdout --inputbox \
	          "Set new date and time
(MM-DD hh:mm YYYY, $clock_tz)" 8 38 "$dtime"`

	if [ "$newdtime" != "$dtime" ] ; then
		echo "Setting new date and time ($newdtime) ..."
		date "$( echo $newdtime | sed 's,[^0-9],,g' )"
		hwclock --systohc --$clock_tz
	fi
}

x=`Xdialog --stdout --no-cancel --combobox "Configure:" 8 38 \
   "Timezone" "Date and Time"`

case "$x" in
	Timezone) set_tmzone ;;
	Date*) set_dtime ;;
esac

