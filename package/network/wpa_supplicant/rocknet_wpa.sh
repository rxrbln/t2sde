# --- T2-COPYRIGHT-BEGIN ---
# t2/package/*/wpa_supplicant/rocknet_wpa.sh
# Copyright (C) 2004 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

wpa_write_conf() {
	local if=$1
	local ssid=${wpa_ssid[$if]}
	local psk=${wpa_psk[$if]}
	# add quotes if necessary
	[[ "$ssid" != \"*\" ]] && ssid="\"$ssid\""
	[[ "$psk" != \"*\" ]] && psk="\"$psk\""

	cat > /var/run/wpa_supplicant-$if.conf <<EOT
ctrl_interface=/var/run/wpa_supplicant
network={
	ssid=$ssid
	psk=$psk
}
EOT
}

wpa_init_if() {
    if isfirst "wpa_$if"; then
	addcode up 5 2 "wpa_write_conf $if"
	addcode up 5 3 "wpa_supplicant -Dnl80211,wext -i$if -B \
-c/var/run/wpa_supplicant-$if.conf -P/var/run/wpa_supplicant-$if.pid"
	addcode down 5 2 "rm -f /var/run/wpa_supplicant-$if.{pid,conf}"
	addcode down 5 3 "kill \$(cat /var/run/wpa_supplicant-$if.pid)"
    fi
}

public_ssid() {
	wpa_init_if
	wpa_ssid[$if]="$*"
}

public_psk() {
	wpa_init_if
	wpa_psk[$if]="$*"
}
