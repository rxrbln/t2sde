
iproute2_init_if() {
	if isfirst "iproute2_$if"; then
		addcode up   5 4 "ip link set $if up"
		addcode down 5 4 "ip link set $if down"
		addcode down 5 5 "ip addr flush dev $if"
	fi
}

public_ip() {
	addcode up 5 5 "ip addr add $1 dev $if"
	iproute2_init_if
}

public_gw() {
	code="ip route add default via $1 dev $if" ; shift

	case "$1" in
	metric)
		code="$code metric $2" ; shift ;;
	esac
	shift

	addcode up 6 5 "$code"
	iproute2_init_if
}

