
echo_status "Copying release_skeleton files"
cd ${releasedir}
cp -r ${base}/target/${target}/${arch}/release_skeleton/* .

unset opt_text
case "${ROCKCFG_X86_OPT}" in
	generic)	opt_text="for all x86 machines";;
	i386)		opt_text="for Intel 386";;
	i486)		opt_text="for Intel 486";;
	via-c3)		opt_text="for VIA CyrixIII/VIA-C3";;
	via-c3-2)	opt_text="for VIA-C3-2 Nemiah";;
	pentium)	opt_text="for Intel Pentium";;
	pentium-mmx)	opt_text="for Intel Pentium with MMX";;
	pentiumpro)	opt_text="for Intel Pentium-Pro";;
	pentium2)	opt_text="for Intel Pentium 2";;
	pentium3)	opt_text="for Intel Pentium 3";;
	pentium4)	opt_text="for Intel Pentium 4";;
	k6)		opt_text="for AMD K6";;
	k6-2)		opt_text="for AMD K6-2";;
	k6-3)		opt_text="for AMD K6-3";;
	athlon)		opt_text="for AMD Athlon";;
	athlon-tbird)	opt_text="for AMD Athlon Thunderbird";;
	athlon4)	opt_text="for AMD Athlon 4";;
	athlon-xp)	opt_text="for AMD Athlon XP";;
	athlon-mp)	opt_text="for AMD Athlon MP" ;;
esac

sed -i -e "s,COMPILEDFOR,${opt_text},g" README

find ${releasedir} -name .svn -exec rm -rf {} \; 2>/dev/null

echo_status "Extracting isolinux boot loader."
mkdir -p isolinux
tar --use-compress-program=bzip2 \
    -xf ${base}/download/${target}/syslinux-2.02.tar.bz2 \
    syslinux-2.02/isolinux.bin -O > ${releasedir}/isolinux/isolinux.bin

echo_status "Creating isolinux config file."
cp ${base}/target/${target}/x86/isolinux.cfg ${releasedir}/isolinux/
cp ${base}/target/${target}/x86/help?.txt ${releasedir}/isolinux/
cp ../root/boot/vmlinuz ${releasedir}/isolinux/

