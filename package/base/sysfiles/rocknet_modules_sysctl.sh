
public_forward() {
	if [ "$if" != "none" ]; then
		error "Keyword >>forward<< not allowed" \
			"in an interface section."
		return
	fi
	[ "$interface" != all ] && return
	addcode up   9 5 "echo 1 > /proc/sys/net/ipv4/ip_forward"
	addcode down 9 5 "echo 0 > /proc/sys/net/ipv4/ip_forward"
}

