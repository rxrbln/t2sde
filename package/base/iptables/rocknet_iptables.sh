
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

iptales_parse_conditions() {
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
	iptales_parse_conditions "$@"
	addcode up 1 5 "iptables -A firewall_$if $iptables_cond -j ACCEPT"
	iptables_init_if
}

public_reject() {
	iptales_parse_conditions "$@"
	addcode up 1 5 "iptables -A firewall_$if $iptables_cond -j REJECT"
	iptables_init_if
}

public_drop() {
	iptales_parse_conditions "$@"
	addcode up 1 5 "iptables -A firewall_$if $iptables_cond -j DROP"
	iptables_init_if
}

