#!/bin/bash

detect_card_old() {
	echo "Trying to autodetect Graphics card"
	echo -n "- nVidia ... "
	if [ `lspci | grep -ic nvidia` -gt 0 ] ; then
		echo "yes"
		driver="nv"
		return 0
	fi
	echo -en "no\n- 3Dfx   ... "
	if [ `lspci | grep -ic 3Dfx` -gt 0 ] ; then
		echo "yes"
		driver="tdfx"
		return 0
	fi
	echo -en "no\n- Matrox ... "
	if [ `lspci | grep -ic Matrox` -gt 0 ] ; then
		echo "yes"
		driver="mga"
		return 0
	fi
	echo -en "no\n- VMware ... "
	if [ `lspci | grep -ic VMware` -gt 0 ] ; then
		echo "yes"
		driver="vmware"
		return 0
	fi
	echo -e "no\nUsing vesa-compatible."
	driver="vesa"
	return 0
}

if [ `grep -c oldxconfig /proc/cmdline` -eq 1 ] ; then
	echo "Running old X-Config"
	detect_card_old
	cat /etc/X11/XF86Config | sed "s,LVPDEVICE,${driver},g" >/tmp/XF86Config
else
	echo -n "Running integrated XFree86-Autoconfiguration ... "
	HOME="/tmp" /usr/X11/bin/X -configure -logfile /dev/null >/dev/null 2>&1
	mv /tmp/XF86Config.new /tmp/XF86Config
	echo "done"
fi
