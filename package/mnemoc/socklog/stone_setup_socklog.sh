#!/bin/sh

D_commanddir/socklog-conf unix nobody log D_sysconfdir D_logdir
D_commanddir/socklog-conf klog nobody log D_sysconfdir D_logdir-klog

for y in unix klog; do
	if [ ! -e "D_servicedir/socklog-$y" ]; then
		ln -s D_sysconfdir/$y D_servicedir/socklog-$y
	fi
done
