
public_udhcp() {
	local opt_nodns=
	local HOSTNAME="`hostname`" cmdline=
	[ "$HOSTNAME" == "(none)" ] && HOSTNAME=
	
	cmdline="/usr/sbin/udhcpc ${HOSTNAME:+-h $HOSTNAME} -i $if"
	cmdline="$cmdline -s /etc/udhcp/t2-default.script"

	while [ $# -ge 1 ]; do
		case "$1" in
			nodns)	opt_nodns=1	;;
			*)	echo "WARNING: udhcp doesn't understand '$1'"
				;;
		esac
		shift
	done
	
	if [ "$opt_nodns" ]; then
		cmdline="export UPDATE_RESOLVCONF=0;
$cmdline"
	fi

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

