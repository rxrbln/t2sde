
public_udhcp() {
	addcode up   5 5 "/usr/sbin/udhcpc -H `hostname` -i $if"
	addcode down 5 5 "killall -TERM udhcpc"
	addcode down 5 6 "sleep 2 ; ip link set $if down || ifconfig $if down"
}

