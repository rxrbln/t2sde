
iptables_init_if() {
	if isfirst "iptables_$if"; then
		addcode up   1 1 "iptables -N firewall_$if"
		addcode up   1 2 "iptables -A INPUT -i $if -j firewall_$if"
		addcode up   1 3 "iptables -A firewall_$if `
			`-m state --state ESTABLISHED,RELATED -j ACCEPT"

		addcode down 1 3 "iptables -F firewall_$if"
		addcode down 1 2 "iptables -D INPUT -i $if -j firewall_$if"
		addcode down 1 1 "iptables -X firewall_$if"
	fi
}

iptables_parse_conditions() {
	iptables_cond=""
	while [ -n "$1" ]
	do
		case "$1" in
		    all)
			shift
			;;
		    tcp|udp)
			iptables_cond="$iptables_cond -p $1 --dport $2"
			shift; shift
			;;
		    ip)
			iptables_cond="$iptables_cond -s $2"
			shift; shift
			;;
		    *)
			error "Unkown accept/reject/drop condition: $1"
			shift
		esac
	done
}

public_accept() {
	iptables_parse_conditions "$@"
	addcode up 1 5 "iptables -A firewall_$if $iptables_cond -j ACCEPT"
	iptables_init_if
}

public_reject() {
	iptables_parse_conditions "$@"
	addcode up 1 5 "iptables -A firewall_$if $iptables_cond -j REJECT"
	iptables_init_if
}

public_drop() {
	iptables_parse_conditions "$@"
	addcode up 1 5 "iptables -A firewall_$if $iptables_cond -j DROP"
	iptables_init_if
}

public_clamp_mtu() {
	addcode up 1 6 "iptables -A FORWARD -p tcp --tcp-flags SYN,RST SYN \
	                -j TCPMSS --clamp-mss-to-pmtu"
	addcode down 9 6  iptables -D FORWARD -p tcp --tcp-flags SYN,RST SYN \
	                  -j TCPMSS --clamp-mss-to-pmtu"
}

public_masquerade() {
	addcode up 1 6 "iptables -t nat -A POSTROUTING -o $if \
	                -j MASQUERADE"
	addcode down 9 6 "iptables -t nat -D POSTROUTING -o $if \
	                  -j MASQUERADE"
}

