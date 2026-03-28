# --- T2-COPYRIGHT-BEGIN ---
# t2/architecture/avr32/linux.conf.sh
# Copyright (C) 2008 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---


if [ -f .config.defconfig ]; then
	cat .config.defconfig
elif [ -f $base/architecture/$arch/linux.conf.m4 ]; then
	m4 -I $base/architecture/$arch -I $base/architecture/share $base/architecture/$arch/linux.conf.m4
else
	echo "# No defaults found"
fi


# too much troubles with the common kernel settings, many drivers do not
# compile cleanly ... :-(

merge_defconfig_and_t2 () {

	m4 -I $base/architecture/$arch -I $base/architecture/share $base/architecture/$arch/linux.conf.m4 > .config.kdef
	cp .config.defconfig .config.k1

	# merge various text/plain config files
	for x in .config.k1 ; do
		if [ -f $x ] ; then
			tag="$(sed '/CONFIG_/ ! d; s,.*CONFIG_\([^ =]*\).*,\1,' $x | tr '\n' '|')"
			egrep -v "\bCONFIG_($tag)\b" < .config.kdef > .config.k2
			sed 's,\(CONFIG_.*\)=n,# \1 is not set,' $x >> .config.k2
		fi
	done

	cat .config.k2
}
