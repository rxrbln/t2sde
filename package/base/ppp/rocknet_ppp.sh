# FIXME: /tmp/.rocknet or such a directory should go to base.sh?
ppp_config_path=/tmp/.rocknet/ppp
[ -d $ppp_config_path ] || mkdir -p $ppp_config_path

# ppp_option <file> ppp-option [...] - add "ppp-option [...]" to the config file 
#                                      specified by <file>
ppp_option() {
	local optfile=$1
	local opt=$2 ; shift 2

	case $opt in 
	hide-password|show-password) optx="hide-password|show-password" ;;
	refuse-chap|require-chap) optx="refuse-chap|require-chap" ;;
	refuse-mschap|require-mschap) optx="refuse-mschap|require-mschap" ;;
	refuse-mschap-v2|require-mschap-v2) optx="refuse-mschap-v2|require-mschap-v2" ;;
	refuse-eap|require-eap) optx="refuse-eap|require-eap" ;;
	refuse-pap|require-pap) optx="refuse-pap|require-pap" ;;
	require-mppe|nomppe) optx="require-mppe|nomppe" ;;
	require-mppe-40|nomppe-40) optx="require-mppe-40|nomppe-40" ;;
	require-mppe-128|nomppe-128) optx="require-mppe-128|nomppe-128" ;;
	noauth|auth) optx="noauth|auth" ;;
	nobsdcomp|bsdcomp) optx="nobsdcomp|bsdcomp" ;;
	nocrtscts|crtscts) optx="nocrtscts|crtscts" ;;
	nocdtrcts|cdtrcts) optx="nocdtrcts|cdtrcts" ;;
	nodefaultroute|defaultroute) optx="nodefaultroute|defaultroute" ;;
	nodeflate|deflate) optx="nodeflate|deflate" ;;
	noendpoint|endpoint) optx="noendpoint|endpoint" ;;
	noipv6|ipv6) optx="noipv6|ipv6" ;;
	noipx|ipx) optx="noipx|ipx" ;;
	noktune|ktune) optx="noktune|ktune" ;;
	nomp|mp) optx="nomp|mp" ;;
	nomppe-stateful|mppe-stateful) optx="nomppe-stateful|mppe-stateful" ;;
	nompshortseq|mpshortseq) optx="nompshortseq|mpshortseq" ;;
	nomultilink|multilink) optx="nomultilink|multilink" ;;
	nopersist|persist) optx="nopersist|persist" ;;
	nopredictor1|predictor1) optx="nopredictor1|predictor1" ;;
	noproxyarp|proxyarp) optx="noproxyarp|proxyarp" ;;
	novj|vj) optx="novj|vj" ;;
	*) optx="$opt" ;;
	esac

	if egrep "^($optx) .*" $optfile 1>/dev/null 2>/dev/null; then
		cp $optfile $optfile.tmp
		optx="`echo $optx | sed 's,|,\\\\|,g'`"
		sed "s,^\($optx\) .*,$opt $*," < $optfile.tmp > $optfile
		rm -f $optfile.tmp
	else
		echo "$opt $*" >> $optfile
	fi
}

# pppoe_config_defaults - create default settings, the respective config file
#                         is \$ppp_${if}_config
pppoe_config_defaults() {
	# FIXME should this be provider dependant, or does this fit for everybody?
	local each
	for each in noipdefault noauth default-asyncmap hide-password noaccomp nobsdcomp \
		    ipcp-accept-local ipcp-accept-remote \
		    nodeflate nopcomp novj novjccomp ktune; do
		 addcode up 4 4 "ppp_option \$ppp_${if}_config $each"
	done
	addcode up 4 5 "ppp_option \$ppp_${if}_config mru 1492"
	addcode up 4 5 "ppp_option \$ppp_${if}_config mtu 1492"
	addcode up 4 5 "ppp_option \$ppp_${if}_config lcp-echo-interval 20"
	addcode up 4 5 "ppp_option \$ppp_${if}_config lcp-echo-failure 3"
	addcode up 4 6 "ppp_option \$ppp_${if}_config ipcp-accept-remote"
	addcode up 4 6 "ppp_option \$ppp_${if}_config ipcp-accept-local"
}

# PUBLIC COMMANDS ###########################################################
# pppoe ppp-interface [config file|auto] [ppp-command-line-arg [...]]
public_pppoe() {
	# default config file
	eval "ppp_${if}_config=$ppp_config_path/option.$if"	
	addcode up 4 3 "echo -n > \$ppp_${if}_config"

	# get unit from $if
	ppp_unit=${if#ppp}

	# parse args
	local ppp_if=$1 ; shift
	local ppp_args=

	# <config file> or "auto" present?
	case $1 in
	auto)
		pppoe_config_defaults
		eval "ppp_args=\"$ppp_args${ppp_args+ }file \$ppp_${if}_config\""
		shift
		;;
	/*)
		eval "ppp_${if}_config=$1"
		eval "ppp_args=\"$ppp_args${ppp_args+ }file \$ppp_${if}_config\""
		shift
		;;
	esac

	# user or password info should not be world readable...
	addcode up 4 3 "chmod 0600 \$ppp_${if}_config"

	ppp_args="$ppp_args${ppp_args+ }`echo $* | sed 's,",\\\\",g'`"

	# fire
	addcode up 5 1 "ip link set $ppp_if down up"
	addcode up 5 2 "/usr/sbin/pppd plugin rp-pppoe.so $ppp_if unit $ppp_unit $ppp_args"
	addcode down 5 2 "[ -f /var/run/$if.pid ] && kill -TERM \`head -n 1 /var/run/$if.pid\`"
	addcode down 5 1 "[ -f /var/run/$if.pid ] && rm -f /var/run/$if.pid"
}

# ppp-option ppp-option [...]
public_ppp_option() {
	local param="`echo $* | sed 's,",\\\\",g'`"
	addcode up 4 6 "ppp_option \$ppp_${if}_config $param"
}

# ppp-on-demand <idle time in seconds>
public_ppp_on_demand() {
	addcode up 4 6 "ppp_option \$ppp_${if}_config demand"
	addcode up 4 6 "ppp_option \$ppp_${if}_config idle $1"
	addcode up 4 6 "ppp_option \$ppp_${if}_config persist"
}
