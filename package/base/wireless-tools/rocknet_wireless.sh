
public_essid() {
	addcode up 4 5 "iwconfig $if essid $*"
}

public_nwid() {
	addcode up 4 5 "iwconfig $if nwid $*"
}

public_domain() {
	addcode up 4 5 "iwconfig $if domain $*"
}

public_freq() {
	addcode up 4 5 "iwconfig $if freq $*"
}

public_channel() {
	addcode up 4 5 "iwconfig $if channel $*"
}

public_sens() {
	addcode up 4 5 "iwconfig $if sens $*"
}

public_mode() {
	addcode up 4 4 "iwconfig $if mode $*"
}

public_ap() {
	addcode up 4 5 "iwconfig $if ap $*"
}

public_nick() {
	addcode up 4 5 "iwconfig $if nick $*"
}

public_rate() {
	addcode up 4 5 "iwconfig $if rate $*"
}

public_rts() {
	addcode up 4 5 "iwconfig $if rts $*"
}

public_frag() {
	addcode up 4 5 "iwconfig $if frag $*"
}

public_key() {
	addcode up 4 5 "iwconfig $if key $*"
}

public_power() {
	addcode up 4 5 "iwconfig $if power $*"
}

public_txpower() {
	addcode up 4 5 "iwconfig $if txpower $*"
}

public_retry() {
	addcode up 4 5 "iwconfig $if retry $*"
}

public_commit() {
        addcode up 4 9 "iwconfig $if commit"
}

