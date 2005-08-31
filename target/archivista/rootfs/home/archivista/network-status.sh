#!/bin/bash

PATH=/sbin:/usr/sbin:$PATH

tmp=`mktemp`

ifconfig eth0 > $tmp
ethtool eth0 >> $tmp

(
	if grep -q UP $tmp; then
		grep "inet addr" $tmp | sed 's/[[:alnum:]]  /\n/g'
	else
		echo not activated
	fi

	echo
	sed -n 's/.*\(HWaddr.*\)/\1/p' $tmp
	echo

	grep -e Speed -e Duplex -e "Link detect" $tmp

	echo
	cat /etc/VERSION
) | sed -e 's/^[[:space:]]\+//' -e 's/inet /Inet /' -e 's/HWaddr /HWaddr:/' \
        -e 's/Bcast:/Bcast: /' -e 's/Mask:/Mask: /' -e 's/addr:/addr: /' |

Xdialog --no-cancel --title "Network status" --logbox - 20 48

rm -f $tmp
