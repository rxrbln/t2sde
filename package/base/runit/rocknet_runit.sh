export CANUSESERVICE=1

service_create() {
	local service_name=$1 runstring="$2" finishstring="$3"

	mkdir -p $rocknet_tmp_base/$service_name/log

	# ./run
	cat <<-EOT > $rocknet_tmp_base/$service_name/run
	#!/bin/sh
	exec 2>&1

	$runstring
	EOT

	# ./log/run
	cat <<-EOT > $rocknet_tmp_base/$service_name/log/run
	#!/bin/sh
	exec 2>&1

	if [ ! -d /var/log/$service_name ]; then
	    mkdir -p /var/log/$service_name
	    chown log /var/log/$service_name
	fi
	exec chpst -ulog svlogd -tt /var/log/$service_name
	EOT

	# ./finish
	if [ "$finishstring" ]; then
		cat <<-EOT > $rocknet_tmp_base/$service_name/finish
		#!/bin/sh
		exec 2>&1

		$finishstring
		EOT
		chmod +x $rocknet_tmp_base/$service_name/finish
	fi
        
	chmod +x $rocknet_tmp_base/$service_name/{,log/}run
	ln -nfs $rocknet_tmp_base/$service_name/ /service/$service_name
}

service_destroy() {
	local service_name=$1 x=

	for x in . log; do
		if [ -d /service/$service_name/$x/supervise ]; then
        		runsvctrl d /service/$service_name/$x
        		svwaitdown /service/$service_name/$x
		fi
	done

	rm -f /service/$service_name
	rm -rf $rocknet_tmp_base/$service_name/
}
