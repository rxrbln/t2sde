# --- T2-COPYRIGHT-BEGIN ---
# t2/package/*/iproute2/rocknet_iproute2.sh
# Copyright (C) 2004 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

iproute2_init_if() {
	if isfirst "iproute2_$if"; then
		addcode up   5 4 "ip link set $if up"
		addcode down 5 4 "ip link set $if down"
		addcode down 5 5 "ip addr flush dev $if"
	fi
}

public_ip() {
	ip="${1%/*}"
	# common config error sanity check
	[ $ip = $1 ] &&
		echo "WARNING: IP has no CIDR network prefix (e.g. /24)!"
	addcode up 5 5 "ip addr add $1 broadcast + dev $if"
	iproute2_init_if
}

public_gw() {
	code="ip route append default via $1 dev $if" ; shift

	case "$1" in
	metric)
		code="$code metric $2" ; shift ;;
	esac
	shift

	addcode up 6 5 "$code"
	iproute2_init_if
}

public_route() {
	code="ip route append $1 via $2 dev $if" ; shift ; shift

	case "$1" in
	metric)
		code="$code metric $2" ; shift ;;
	esac
	shift

	addcode up 6 5 "$code"
	iproute2_init_if
}

public_mac() {
	addcode up 4 3 "ip link set $if address $1"
	iproute2_init_if
}
