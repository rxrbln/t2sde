
dns_init() {
	if isfirst "dns"; then
		addcode up   4 1 "echo -n "" > /etc/resolv.conf"
	fi
}

public_nameserver() {
	addcode up 4 5 "echo nameserver $1 >> /etc/resolv.conf"
	dns_init
}

public_search() {
	if ! isfirst "dns_search"; then
		error "Keyword >>search<< not allowed multiple times."
		return
	fi

	addcode up 4 4 "echo search $* >> /etc/resolv.conf"
	dns_init
}

