
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
		optx="`echo $optx | sed 's,|,\\\\|,g'`"
		sed -i "s,^\($optx\) .*,$opt $*," $optfile
	else
		echo "$opt $*" >> $optfile
	fi
}

chat_init_if() {
    if isfirst "chat_$if" ; then
	addcode up 4 1 "echo -n > \$ppp_${if}_chat"
	addcode up 4 6 "ppp_option \$ppp_${if}_config \
	                connect \'chat -v -f \$ppp_${if}_chat\'"
    fi
}

# PUBLIC COMMANDS ###########################################################
# pppoe ppp-interface [config file|auto] [ppp-command-line-arg [...]]
public_ppp() {
	# config file
	eval "ppp_${if}_config=$rocknet_tmp_base/ppp_${if}_options"
	eval "ppp_${if}_chat=$rocknet_tmp_base/ppp_${if}_chat"

	# get unit from $if
	ppp_unit=${if#ppp}

	# parse args
	ppp_if=$1 ; shift
	local ppp_args="`echo $* | sed 's,",\\\\",g'`"

	addcode up 4 1 "echo -n > \$ppp_${if}_config"
	addcode up 4 2 "chmod 0600 \$ppp_${if}_config"

	ppp_command="/usr/sbin/pppd file \$ppp_${if}_config $ppp_if"
	ppp_command="$ppp_command unit $ppp_unit"
	ppp_command="$ppp_command $ppp_args"

	if [ "$CANUSESERVICE" == "1" ]; then
		addcode up 5 1 "service_create $if 'ip link set $ppp_if down up
exec `eval echo $ppp_command` nodetach' \
			'[ -f /var/run/$if.pid ] && rm -f /var/run/$if.pid'"
		addcode down 5 1 "service_destroy $if"
	else
		addcode up 6 2 "$ppp_command"

		addcode down 5 5 "[ -f /var/run/$if.pid ] && kill -TERM \`head -n 1 /var/run/$if.pid\`" 
		addcode down 5 4 "[ -f /var/run/$if.pid ] && rm -f /var/run/$if.pid"
	fi
}

public_pppoe() {
	addcode up 4 5 "ppp_option \$ppp_${if}_config plugin rp-pppoe.so"
	addcode up 4 5 "ppp_option \$ppp_${if}_config mru 1492"
	addcode up 4 5 "ppp_option \$ppp_${if}_config mtu 1492"

	if [ "$CANUSESERVICE" != "1" ]; then
		addcode up 5 1 "ip link set $ppp_if up"
	fi
}

public_ppp_defaults() {
        local each
        for each in noipdefault noauth hide-password \
	            ipcp-accept-local ipcp-accept-remote \
	            defaultroute usepeerdns ; do
		addcode up 4 4 "ppp_option \$ppp_${if}_config $each"
	done
}

public_ppp_speed_defaults() {
	local each
	for each in default-asyncmap noaccomp nobsdcomp nodeflate nopcomp \
	            novj novjccomp ktune ; do
		addcode up 4 4 "ppp_option \$ppp_${if}_config $each"
	done

        addcode up 4 5 "ppp_option \$ppp_${if}_config lcp-echo-interval 20"
        addcode up 4 5 "ppp_option \$ppp_${if}_config lcp-echo-failure 3"
}

public_ppp_option() {
	local param="`echo $* | sed 's,",\\\\",g'`"
	addcode up 4 6 "ppp_option \$ppp_${if}_config $param"
}

public_ppp_on_demand() {
	addcode up 4 6 "ppp_option \$ppp_${if}_config demand"
	addcode up 4 6 "ppp_option \$ppp_${if}_config idle $1"
	addcode up 4 6 "ppp_option \$ppp_${if}_config persist"
}

public_chat_defaults() {
	chat_init_if

	addcode up 4 1 "echo 'ABORT \"NO CARRIER\"
ABORT \"NO DIALTONE\"
ABORT \"ERROR\"
ABORT \"NO ANSWER\"
ABORT \"BUSY\"
\"\" \"at\"' >> \$ppp_${if}_chat"
}

public_chat_init() {
	chat_init_if
	# don't ask and count ...
	opts="`echo "$@" | sed -e 's/"/\\\\\\\\\\\\\"/g' \
	                       -e 's/&/\\\\\\&/g'`"
	addcode up 4 3 "echo '\"OK\" \"$opts\"' >> \$ppp_${if}_chat"
}

public_chat_dial() {
	chat_init_if
	# don't ask and count ...
	opts="`echo "$@" | sed 's/"/\\\\\\\\\\\\\"/g'`"
	addcode up 4 5 "echo -e '\"OK\" \"$opts\"\n\"CONNECT\" \"\"' >> \$ppp_${if}_chat"
}

