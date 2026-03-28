# --- T2-COPYRIGHT-BEGIN ---
# t2/package/*/rocknet/rocknet_dns.sh
# Copyright (C) 2004 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

dns_init() {
	if isfirst "dns"; then
		addcode up   4 1 "echo -n "" > /etc/resolv.conf"
	fi
}

public_nameserver() {
	addcode up 4 5 "echo nameserver $1 >> /etc/resolv.conf"
	dns_init
}

public_ns() {
	public_nameserver "$1"
}

public_search() {
	if ! isfirst "dns_search"; then
		error "Keyword >>search<< not allowed multiple times."
		return
	fi

	addcode up 4 4 "echo search $* >> /etc/resolv.conf"
	dns_init
}

public_hostname() {
	addcode up 9 5 "hostname $1"
}

public_domainname() {
	# THIS IS (still) A HACK
	addcode up 9 5 "sed -i 's/`hostname`\..* /`hostname`.$1 /' /etc/hosts"
}
