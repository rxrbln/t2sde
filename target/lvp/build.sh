
lvp_ver="0.4.0"
releasedir="${base}/build/${ROCKCFG_ID}/lvp_${lvp_ver}_${ROCKCFG_X86_OPT}"

pkgloop

. scripts/parse-config
PATH="${base}/build/${ROCKCFG_ID}/${toolsdir}/diet-bin:${PATH}"

echo_header "Creating LVP ..."

echo_header "Checking for *.err files ..."
if [ `find "${base}/build/${ROCKCFG_ID}/root/var/adm/logs/" -name '*err' 2>/dev/null | wc -l` -gt 0 ] ; then
	echo_status "Found some. This is bad :-("
else
	echo_status "None found. Good :-)"

	echo_status "(Re)creating releasedir"
	rm -rf ${releasedir}
	mkdir -p ${releasedir}
	chmod 700 ${releasedir}

	if [ -f ${base}/target/${target}/${arch}/build.sh ]; then
		echo_status "Executing ${arch} specific build instructions."
		. ${base}/target/${target}/${arch}/build.sh
	fi

	echo_status "Creating the live-system"

	kernelversion="`grep '\[V\]' ${base}/package/base/linux24/linux24.desc | cut -f2 -d' '`"

	echo_status "Creating directory structure"
	cd ${releasedir}/livesystem
	tar xfI ${base}/build/${ROCKCFG_ID}/pkgs/00-dirtree.tar.bz2
	cd usr/
	rm -rf X11 X11R6
	mkdir X11R6
	ln -sf X11R6 X11
	cd ..

	echo_status "Copying programs"

	for x in \
		bin/bash \
		bin/cat \
		bin/find \
		bin/gawk \
		bin/grep \
		bin/gzip \
		bin/ln \
		bin/loadkeys \
		bin/mount \
		bin/mv \
		bin/rm \
		bin/sed \
		bin/sh \
		bin/uname \
		etc/mplayer/mplayer.conf \
		lib/modules/${kernelversion}-rock/block \
		sbin/agetty \
		sbin/hwscan \
		usr/share/mplayer/font-arial-24-iso-8859-1 \
		usr/X11/bin/XFree86 \
		usr/X11/bin/X \
		usr/X11/bin/startx \
		usr/X11/bin/xauth \
		usr/X11/bin/xinit \
		usr/X11/bin/xterm \
		usr/X11/lib/X11/fonts/misc \
		usr/bin/lvp \
		usr/bin/mplayer \
		usr/bin/tail \
		usr/sbin/lspci \
		usr/share/kbd/keymaps ; do

		mkdir -p ${x%/*}
		cp -ar ${base}/build/${ROCKCFG_ID}/root/${x} ${x}
		chmod u-s,g-s ${x}
		dynamic=`file ${x} | grep -c dynamic`
		if [ "${dynamic}" != "0" ] ; then
			echo_error "WARNING! ${x} is NOT linked statically!"
		fi
	done

	cd etc/
	ln -sf /proc/mounts mtab
	cd ..
	cd usr/share/mplayer
	ln -sf font-arial-24-iso-8859-1 font
	cd ../../..

	echo_status "Copying linuxrc as init-replacement ..."
	cp ${base}/target/${target}/linuxrc ${releasedir}/livesystem/linuxrc ; chmod +x ${releasedir}/livesystem/linuxrc
	echo_status "Copying sbin/login-shell ..."
	cp ${base}/target/${target}/login-shell ${releasedir}/livesystem/sbin/login-shell ; chmod +x ${releasedir}/livesystem/sbin/login-shell
	echo_status "Copying startlvp script ..."
	cp ${base}/target/${target}/startlvp ${releasedir}/livesystem/sbin/; chmod +x ${releasedir}/livesystem/sbin/startlvp
	echo_status "Copying XF86Config ..."
	mkdir -p ${releasedir}/livesystem/etc/X11
	cp ${base}/target/${target}/XF86Config ${releasedir}/livesystem/etc/X11/XF86Config
	echo_status "Copying xinitrc ..."
	mkdir -p ${releasedir}/livesystem/usr/X11R6/lib/X11/xinit
	cp ${base}/target/${target}/xinitrc ${releasedir}/livesystem/usr/X11R6/lib/X11/xinit/xinitrc
	echo_status "Copying etc scripts ..."
	mkdir -p ${releasedir}/livesystem/etc/lvp
	for x in ${base}/target/${target}/etc_* ; do
		y=${x##*/}
		cp ${x} ${releasedir}/livesystem/${y//_/\/}
	done
	echo_status "Copying kernel modules ..."
	cd ${releasedir}/livesystem
	tar xfI ${base}/build/${ROCKCFG_ID}/pkgs/linux24.tar.bz2 lib/
	cp ${base}/build/${ROCKCFG_ID}/root/sbin/insmod.static ${releasedir}/livesystem/sbin/insmod
	for x in kallsyms ksyms lsmod modprobe rmmod ; do
		ln -sf /sbin/insmod ${releasedir}/livesystem/sbin/${x}
	done

	echo_status "Compressing binaries ... "
	${base}/build/${ROCKCFG_ID}/root/usr/bin/upx --best --crp-ms=999999 --nrv2d `find ${releasedir}/livesystem -type f | xargs file | grep "statically linked" | grep -v bin/bash | grep -v bin/mount | cut -f1 -d:` >/proc/$$/fd/1 2>/proc/$$/fd/2 </proc/$$/fd/0

fi
echo_status "LVP v${lvp_ver} built for ${ROCKCFG_X86_OPT} is now ready in ${releasedir}."

cd ${base}
