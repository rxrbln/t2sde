
public_dhcpcd() {
	local pidfile=/etc/dhcpc/dhcpcd-$if.pid
	if [ -f $pidfile ]; then
		addcode up   5 4 "[ -f $pidfile -a ! -d /proc/\$( cat $pidfile ) ] && rm -f $pidfile"
		addcode down 5 4 "rm -f $pidfile"
	fi
	addcode up   5 5 "/usr/sbin/dhcpcd -h $( hostname ) -d -D $if"
	addcode down 5 5 "[ -f $pidfile ] && kill -15 \$( cat $pidfile )"
}

