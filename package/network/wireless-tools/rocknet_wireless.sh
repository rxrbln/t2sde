
public_essid() {
	addcode up 4 5 "iwconfig $if essid $*"
	addcode down 4 5 "iwconfig $if essid any"
}

public_nwid() {
	addcode up 4 5 "iwconfig $if nwid $*"
	addcode down 4 5 "iwconfig $if nwid off"
}

public_domain() {
	addcode up 4 5 "iwconfig $if domain $*"
	addcode down 4 5 "iwconfig $if domain off"
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
	addcode down 4 4 "iwconfig $if mode Auto"
}

public_ap() {
	addcode up 4 5 "iwconfig $if ap $*"
	addcode down 4 5 "iwconfig $if ap any"
}

public_nick() {
	addcode up 4 5 "iwconfig $if nick $*"
}

public_rate() {
	addcode up 4 5 "iwconfig $if rate $*"
	addcode down 4 5 "iwconfig $if rate auto"
}

public_rts() {
	addcode up 4 5 "iwconfig $if rts $*"
}

public_frag() {
	addcode up 4 5 "iwconfig $if frag $*"
}

public_key() {
	addcode up 4 5 "iwconfig $if key $*"
	addcode down 4 5 "iwconfig $if key off"
}

public_enc() {
        addcode up 4 5 "iwconfig $if enc $*"
	addcode down 4 5 "iwconfig $if enc off"
}

public_power() {
	addcode up 4 5 "iwconfig $if power $*"
}

public_txpower() {
	addcode up 4 5 "iwconfig $if txpower $*"
	addcode down 4 5 "iwconfig $if txpower auto"
}

public_retry() {
	addcode up 4 5 "iwconfig $if retry $*"
}

public_commit() {
        addcode up 4 9 "iwconfig $if commit"
}

