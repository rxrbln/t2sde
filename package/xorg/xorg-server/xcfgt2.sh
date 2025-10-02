#!/bin/bash
# --- T2-COPYRIGHT-BEGIN ---
# t2/package/*/xorg-server/xcfgt2.sh
# Copyright (C) 2005 - 2025 The T2 SDE Project
# Copyright (C) 2005 - 2025 René Rebe, ExactCODE GmbH
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

# Quick T2 SDE live X driver matching ...

var_append() {
	local x="${3// /}"
	eval "[ \"\$$1\" ] && $1=\"\${$1}$2\"" || true
	eval "$1=\"\${$1}\$x\""
}

tmp=`mktemp`

echo "XcfgT2 (C) 2005 - 2025 Rene Rebe, ExactCODE GmbH"

sysid=
if [ -d /sys/devices/virtual/dmi/id ]; then
  for i in sys_vendor product_name chassi_vendor board_name product_serial board_serial; do
  	var_append sysid ':' "$(cat /sys/devices/virtual/dmi/id/$i 2>/dev/null)"
  done
fi

# Apple Inc.:MacBookPro3,1:Apple Inc.:Mac-F4238BC8::
# PhoenixAward:945GM:PhoenixAward:945GM:0123456789:
# ::IntelCorporation:D945GCLF2::
# ASUSTeK Computer INC.:900:ASUSTeK Computer INC.:900:EeePC-1234567890:EeePC
echo "SystemID: $sysid"

xdrv= depth= fbdev=

# start by mapping primary RISC workstation framebuffers
while read fb; do
    n=${fb%% *}
    fb=${fb#* }
    case "${fb,,}" in
	elite\ 3d|creator) xdrv=sunffb fbdev=fb$fb ;;
    esac
done < <(cat /proc/fb)

[ "$fbdev" ] &&
	card=$(cat /sys/class/graphics/$fbdev/name 2>/dev/null) ||
	card=$(lspci | sed -n 's/.*[^-]VGA[^:]*: //p') # not Non-VGA

echo "Video card: $card"

# map from pci
[ "$xdrv" ] ||
case "${card,,}" in
	*radeon*)	xdrv=radeon ;;
	*geforce*)	xdrv=nouveau ;;
	*cirrus*)	xdrv=cirrus ;;
	*savage*)	xdrv=savage ;;
	*virge*)	xdrv=s3virge ;;
	ps3*fb)		xdrv=fbdev ;;
	*intel*8*|*intel*9*|*intel*mobile*)	xdrv=intel ;;
	*intel*7*)	xdrv=i740 ;;

	*trident*)	xdrv=trident depth=16 ;;
	*rendition*)	xdrv=rendition ;;
	*neo*)		xdrv=neomagic ;;
	*tseng*)	xdrv=tseng ;;

	*parhelia*)	xdrv=mtx ;;
	*matrox*)	xdrv=mga ;;

	*cyrix*)	xdrv=cyrix ;;
	*silicon\ motion*)	xdrv=siliconmotion ;;
	*chips*)	xdrv=chips ;;

	*3dfx*)		xdrv="tdfx" ;;
	*permedia*|*glint*)	xdrv="glint" ;;

	*vmware*)	xdrv="vmware" ;;
	*qxl*)		xdrv="qxl" ;;

	*ark\ logic*)	xdrv="ark" ;;
	*dec*tga*)	xdrv="tga" ;;

	*national\ semi*)	xdrv=nsc ;;
	*geode*)	xdrv=geode ;;

	*mach64*)	xdrv=mach64 depth=16 ;;
	*ati\ *)	xdrv=ati ;;
	*sis*|*xgi*)	xdrv=sis depth=16 ;;

	*chrome*|*castlerock*)	xdrv=openchrome ;;
	*s3*)		xdrv=s3 ;;

	creator\ 3d|elite\ 3d)	xdrv=sunffb ;;
	bwtwo)		xdrv=sunbw2 depth=1 ;;
	cgthree) 	xdrv=suncg3 depth=8 ;;
	gx*|tgx*)	xdrv=suncg6 depth=8 ;;
	cgfourteen)	xdrv=suncg6 depth=32 ;;
	tcx8)		xdrv=suntcx depth=8 ;;
	tcx24)		xdrv=suntcx depth=32 ;;
	*leo)		xdrv=sunsun depth=32 ;;

	# must be last so *nv* does not match one of the above
	*nv*)		xdrv=nv
esac

# fallback to either vesa or fbdev ...
[ "$xdrv" ] ||
case $(uname -m) in
	i*86*|x86*64)	xdrv=vesa ;;
	*)		xdrv=fbdev ;;
esac

# maybe binary nvidia driver?
[ "$xdrv" = nv -a -f /usr/X11/lib/xorg/modules/drivers/nvidia_drv.so ] &&
	xdrv=nvidia

cmdline="$(< /proc/cmdline)"

# manual override
xdriver="xdriver= $cmdline" xdriver=${xdriver##*xdriver=} xdriver=${xdriver%% *}
[ "$xdriver" ] && xdrv="$xdriver"

case "$xdrv" in
	#fbdev|nv|nvidia|sunffb) depth=24 ;;
	vmware) depth= ;;
esac

# manual override
xdepth="xdepth= $cmdline" xdepth=${xdepth##*xdepth=} xdepth=${xdepth%% *}
[ "$xdepth" ] && depth="$xdepth"


# use the nvidia binary only driver - if available ...
if [ "$xdrv" = "nvidia" ]; then
	echo "Installing nvidia GL libraries and headers ..."
	rm -rf /usr/X11/lib/libGL.*
	cp -arv /usr/src/nvidia/lib/* /usr/X11/lib/
	cp -arv /usr/src/nvidia/X11R6/lib/* /usr/X11/lib/
	cp -arv /usr/src/nvidia/include/* /usr/X11/lib/GL/
	ln -sf /usr/X11/lib/xorg/modules/extensions/{libglx.so.1.0.*,libglx.so}

	echo "Updating dynamic library database ..."
	ldconfig /usr/X11/lib
fi

horiz_sync=
vert_refresh=
modes=
ddc=1

# manual, boot command line overrides
xmodes="xmodes= $cmdline" xmodes=${xmodes##*xmodes=}; xmodes=${xmodes%% *}
xddc="xddc= $cmdline" xddc=${xddc##*xddc=}; xddc=${xddc%% *}

[ "$xmodes" ] && modes="$(echo $xmodes | sed 's/,/ /g; s/[^ ]\+/"&"/g')"
[ "$xddc" ] && ddc="$xddc"


# if ddcprobe available, ddc not disabled and no manual modes
if type -p ddcprobe > /dev/null && [ "$ddc" = 1 ] && [ -z "$modes" ]; then
	echo "Probing for DDC information ..."
	ddcprobe > $tmp

	if grep -q failed $tmp; then
	  echo "DDC read failed"
	else
	  defx=`grep "Horizontal blank time" $tmp | cut -d : -f 2 |
	        sort -nu | tail -n 1`
	  defy=`grep "Vertical blank time" $tmp | cut -d : -f 2 |
	        sort -nu | tail -n 1`

	  defx=${defx:-0}
	  defy=${defy:-0}

	  while read m; do
		x=${m/x*/}
		y=${m/*x/}
		if [ $defx -eq 0 -o $x -le $defx ] &&
		   [ $defy -eq 0 -o $y -le $defy ]; then
			echo "mode $x $y ok"
			modes="$modes \"${x}x${y}\""
		else
			echo "mode $x $y skipped"
		fi
	  done < <( grep -A 1000 '^Established' $tmp |
	  grep -B 1000 '^Standard\|^Detailed' |
	  sed -e 's/[\t ]*\([^ ]*\).*/\1/' -e '/^[A-Z]/d' |
	  sort -rn | uniq )
	fi
fi

# if still no mode try to determine from FB (mostly for
# non PC workstations / embedded devices with system FB)
if [ -z "$modes" ]; then
	for mode in `sed -n 's/.:\([[:digit:]]\+x[[:digit:]]\+\)[[:alpha:]]*-[[:digit:]]\+/\1/p' \
		/sys/class/graphics/$fbdev/modes 2>/dev/null | sort -r -n -u`; do
		modes="$modes \"$mode\""
	done
	modes="${modes# *}"
fi

# still no modes, use backward / safe compatible defaults
if [ -z "$modes" ]; then
	echo "No modes from DDC or FB detection, using defaults!"
	modes='"1024x768" "800x600" "640x480"'
	horiz_sync="HorizSync   24.0 - 65.0"
	vert_refresh="VertRefresh 50 - 75"
fi


echo "X Driver:    $xdrv"
echo "Using modes: $modes"
echo "    @ depth: $depth"
[ "$hoiz_sync" -o "$vert_refresh" ] &&
echo "      horiz: $horiz_sync" &&
echo "       vert: $vert_refresh"

[ -f /etc/X11/xorg.conf ] && cp /etc/X11/xorg.conf /etc/X11/xorg.conf.bak

sed -e "s/\$xdrv/$xdrv/g" -e "s/\$modes/$modes/g" -e "s/\$depth/$depth/g" \
    -e "s/\$horiz_sync/$horiz_sync/g" \
    -e "s/\$vert_refresh/$vert_refresh/g" \
    /etc/X11/xorg.conf.template > /etc/X11/xorg.conf

if [ -z "$depth" ]; then
	sed -i '/DefaultDepth/d' /etc/X11/xorg.conf
fi

if [ "$ddc" = 0 ]; then
	echo "Adding NoDDC option"
	sed -i 's/.*Ident.*Card.*/&\n    Option\t"NoDDC"\n/' /etc/X11/xorg.conf
fi

rm $tmp
