
lvp_ver="0.4.1"
rootdir="${base}/build/${ROCKCFG_ID}"
ROCKdir="${rootdir}/ROCK"
releasedir="${ROCKdir}/lvp_${lvp_ver}_${ROCKCFG_X86_OPT}"
syslinux_ver="`sed -n 's,.*syslinux-\(.*\).tar.*,\1,p' ${base}/target/${target}/download.txt`"
kernelversion="`grep '\[V\]' ${base}/package/base/linux24/linux24.desc | cut -f2 -d' '`"

pkgloop

. scripts/parse-config
PATH="${base}/build/${ROCKCFG_ID}/${toolsdir}/diet-bin:${PATH}"

echo_header "Creating LVP ..."

echo_header "Checking for *.err files ..."
if [ `find "${rootdir}/var/adm/logs/" -name '*err' 2>/dev/null | wc -l` -gt 0 ] ; then
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

	echo_status "Creating initrd"
	echo_status "Creating directory structure"
	mkdir -p ${releasedir}/initrd
	cd ${releasedir}/initrd
	mkdir -p bin etc proc dev tmp mnt
	ln -sf bin sbin
	ln -sf . usr
	cd etc
	ln -sf /proc/mounts mtab
	ln -sf /proc/mounts fstab
	cd ..
	
	echo_status "Copying programs"
	for x in \
		bin/bash \
		bin/cat \
		bin/grep \
		bin/gzip \
		bin/ln \
		bin/ls \
		bin/mount \
		bin/umount \
		bin/rm \
		usr/bin/chroot \
		bin/find \
		bin/gawk \
		bin/loadkeys \
		lib/modules/${kernelversion}-rock/block \
		sbin/agetty \
		sbin/hwscan \
		usr/bin/eject \
		usr/sbin/lspci \
		usr/share/kbd/keymaps ; do

		mkdir -p ${x%/*}
		cp -ar ${rootdir}/${x} ${x}
		chmod u-s,g-s ${x}
		dynamic=`file ${x} | grep -c dynamic`
		if [ "${dynamic}" != "0" ] ; then
			echo_error "WARNING! ${x} is NOT linked statically!"
		fi
	done

	cp ${base}/target/${target}/${arch}/initrd/* bin/
	cd bin
	chmod +x *
	ln -sf gzip gunzip
	ln -sf gzip gzcat
	cd ..
	mv bin/linuxrc .

	cp ${rootdir}/sbin/insmod.static ${releasedir}/initrd/sbin/insmod
	for x in kallsyms ksyms lsmod modprobe rmmod ; do
		ln -sf /sbin/insmod ${releasedir}/initrd/sbin/${x}
	done

	echo_status "Copying kernel modules to initrd"
	cd ${releasedir}/initrd
	tar --use-compress-program=bzip2 -xf ${ROCKdir}/pkgs/linux24.tar.bz2 lib/

	echo_status "Creating the livesystem"
	echo_status "Creating directory structure"
	mkdir -p ${releasedir}/livesystem
	cd ${releasedir}/livesystem
	tar --use-compress-program=bzip2 -xf ${ROCKdir}/pkgs/00-dirtree.tar.bz2
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
		bin/grep \
		bin/gzip \
		bin/ln \
		bin/mount \
		bin/mv \
		bin/rm \
		bin/sed \
		bin/sh \
		bin/uname \
		bin/umount \
		etc/mplayer/mplayer.conf \
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
		sbin/losetup \
		; do

		mkdir -p ${x%/*}
		cp -ar ${rootdir}/${x} ${x}
		chmod u-s,g-s ${x}
		dynamic=`file ${x} | grep -c dynamic`
		if [ "${dynamic}" != "0" ] ; then
			echo_error "WARNING! ${x} is NOT linked statically!"
		fi
	done

	cd etc/
	ln -sf /proc/mounts mtab
	cd ../usr/share/mplayer
	mv font-arial-24-iso-8859-1 font
	cd ../../..

	echo_status "Copying linuxrc as init-replacement ..."
	cp ${base}/target/${target}/${arch}/livesystem/linuxrc ${releasedir}/livesystem/linuxrc ; chmod +x ${releasedir}/livesystem/linuxrc
	echo_status "Copying startlvp script ..."
	cp ${base}/target/${target}/${arch}/livesystem/startlvp ${releasedir}/livesystem/sbin/; chmod +x ${releasedir}/livesystem/sbin/startlvp
	echo_status "Copying XF86Config ..."
	mkdir -p ${releasedir}/livesystem/etc/X11
	cp ${base}/target/${target}/${arch}/livesystem/XF86Config ${releasedir}/livesystem/etc/X11/XF86Config
	echo_status "Copying xinitrc ..."
	mkdir -p ${releasedir}/livesystem/usr/X11R6/lib/X11/xinit
	cp ${base}/target/${target}/${arch}/livesystem/xinitrc ${releasedir}/livesystem/usr/X11R6/lib/X11/xinit/xinitrc
	echo_status "Copying etc scripts ..."
	mkdir -p ${releasedir}/livesystem/etc/lvp
	for x in ${base}/target/${target}/${arch}/livesystem/etc_* ; do
		y=${x##*/}
		cp ${x} ${releasedir}/livesystem/${y//_/\/}
	done

	echo "LVP v${lvp_ver}" >>${releasedir}/livesystem/etc/VERSION

	echo_status "Compressing binaries ... "
	${rootdir}/usr/bin/upx --best --crp-ms=999999 --nrv2d `find ${releasedir}/livesystem -type f | xargs file | grep "statically linked" | grep -v bin/bash | grep -v bin/mount | cut -f1 -d:` `find ${releasedir}/initrd -type f | xargs file | grep "statically linked" | grep -v bin/bash | grep -v bin/mount | cut -f1 -d:` >/proc/$$/fd/1 2>/proc/$$/fd/2 </proc/$$/fd/0

	echo_status "Creating initrd.img"
	dd if=/dev/zero of=${releasedir}/isolinux/initrd bs=1k count=8192
	mkfs.ext2 -m 0 -F ${releasedir}/isolinux/initrd >/dev/null 2>&1
	mkdir ${releasedir}/initrd.tmp.$$
	mount -o loop ${releasedir}/isolinux/initrd ${releasedir}/initrd.tmp.$$
	mv ${releasedir}/initrd/* ${releasedir}/initrd.tmp.$$
	umount ${releasedir}/initrd.tmp.$$
	rm -rf ${releasedir}/initrd.tmp.$$ ${releasedir}/initrd

	echo_status "LVP v${lvp_ver} built for ${ROCKCFG_X86_OPT} is now ready in ${releasedir}."
fi

cd ${base}
