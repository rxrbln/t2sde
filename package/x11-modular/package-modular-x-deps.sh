#!/bin/bash

i=400

tune_prio ()
{
	pkg=`echo $1 | tr A-Z a-z`
	sed -i "s/\[P\] .*/[P] X -----5---9 $2/" package/*/$pkg/$pkg.desc
}

for x in bigreqs composite damage dmx evie fixes fontcache fonts gl input \
    kb print randr record render resource scrnsaver trap video x \
    xcmisc xext xf86bigfont xf86dga xf86dri xf86misc xf86rush xf86vidmode \
    xinerama panoramix ; do
	case $x in
	evie)
		tune_prio ${x}ext 112.$i ;;
	*)
		tune_prio ${x}proto 112.$i ;;
	esac

done

for x in xtrans Xau Xdmcp X11 Xext dmx fontenc FS ICE lbxutil oldX SM \
    Xt Xmu Xpm Xp Xaw Xfixes Xcomposite Xrender Xdamage Xcursor Xevie \
    Xfont Xfontcache Xft Xi Xinerama xkbfile xkbui XprintUtil XprintAppUtil \
    Xrandr XRes XScrnSaver XTrap Xtst Xv XvMC Xxf86dga Xxf86misc Xxf86vm ; do

	case $x in
	xtrans)
		tune_prio $x 112.$((i++)) ;;
	*)
		tune_prio lib$x 112.$((i++)) ;;
	esac
done

tune_prio mkfontscale 112.550
tune_prio xserver 112.$(( i++ ))
tune_prio xorg 112.$(( i++ ))

tune_prio xbitmaps 112.$(( i++ ))

tune_prio font-util 112.$(( i++ ))

tune_prio xorg-server 112.$(( i++ ))

