
public_dhcp() {
	addcode up   5 5 "/sbin/dhclient -q $if"
	addcode down 5 5 "killall -TERM dhclient"
	addcode down 5 6 "sleep 2 ; ip link set $if down || ifconfig $if down"
}

