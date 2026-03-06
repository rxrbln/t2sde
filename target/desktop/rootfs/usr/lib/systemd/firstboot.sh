#!/bin/bash
# --- T2-COPYRIGHT-BEGIN ---
# t2/target/desktop/rootfs/usr/lib/systemd/firstboot.sh
# Copyright (C) 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

. /etc/profile

echo "Running firstboot services"
for p in /etc/postinstall.d/*; do
	echo $p
	$p >/dev/null 2>&1
done

locales="bg_BG.UTF-8 cs_CZ.UTF-8 da_DK.UTF-8 de_DE.UTF-8 el_GR.UTF-8 \
en_GB.UTF-8 en_US.UTF-8 es_ES.UTF-8 es_MX.UTF-8 et_EE.UTF-8 fi_FI.UTF-8 \
fr_FR.UTF-8 hr_HR.UTF-8 hu_HU.UTF-8 it_IT.UTF-8 ja_JP.UTF-8 ko_KR.UTF-8 \
lt_LT.UTF-8 lv_LV.UTF-8 nl_NL.UTF-8 pl_PL.UTF-8 pt_BR.UTF-8 pt_PT.UTF-8 \
ro_RO.UTF-8 ru_RU.UTF-8 sk_SK.UTF-8 sl_SI.UTF-8 sv_SE.UTF-8 th_TH.UTF-8 \
tr_TR.UTF-8 uk_UA.UTF-8 zh_CN.UTF-8 zh_TW.UTF-8"

if [[ "$(uname -m)" != *86* ]]; then
	systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

	modprobe zram
	zramctl -f -s 64m
	mkswap /dev/zram0
	swapon /dev/zram0 -p 200
fi

set +m
maxjobs=$(nproc)
[ "$maxjobs" -le 2 ] && locales=""
for l in C.UTF-8 $locales; do
	echo -n "$l "
	localedef -i ${l%.*} -c -f ${l#*.} $l &
	if [ $((--maxjobs)) -le 0 ]; then
		wait -n
		((++maxjobs))
	fi
done
echo

useradd -u 1000 user -G audio,input,kvm,video,wheel 2>/dev/null
su user -c "xdg-user-dirs-update"
chpasswd <<-EOT
root:password
user:password
EOT

wait
