
public_udhcp() {
	local cmdline="/usr/sbin/udhcpc -h `hostname` -i $if"
	cmdline="$cmdline -s /etc/udhcp/t2-default.script"

	if [ "$CANUSESERVICE" == "1" ]; then
		addcode up 5 1 "service_create $if '$cmdline -f'" \
			"sleep 2 ; ip link set $if down"
		addcode down 5 1 "service_destroy $if"
	else
		addcode up   5 5 "$cmdline"
		addcode down 5 5 "killall -TERM udhcpc"
		addcode down 5 5 "sleep 2 ; ip link set $if down"
	fi
}

