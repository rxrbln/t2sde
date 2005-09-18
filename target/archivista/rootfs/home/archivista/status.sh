#!/bin/bash

. /etc/profile

tmp=`mktemp`

ifconfig eth0 > $tmp
ethtool eth0 >> $tmp

(
	if grep -q UP $tmp; then
		grep "inet addr" $tmp | sed 's/\([[:alnum:]]\)  /\1\n/g'
	else
		echo not activated
	fi

	echo
	sed -n 's/.*\(HWaddr.*\)/\1/p' $tmp
	echo

	grep -e Speed -e Duplex -e "Link detect" $tmp

	if ps ax | grep -q sshd; then
		echo "Remote access (SSH) active"
	else
		echo "Remote access (SSH not active"
	fi

	read m h junk  < <(grep "archivista.backup" /etc/crontab)
	if [ "$h" -a "$m" ]; then
		echo "Tape Backup enabled at $h:$m"
	else
		echo "Tape Backup not enabled"
	fi

	read junk junk id < <(grep 'server-id' /etc/my.cnf)
	case $id in
	1) echo "Database in master mode" ;;
	2) echo "Database in slave mode" ;;
	*) echo "Databse in normal mode" ;;
	esac

	echo
	cat /etc/VERSION
) | sed -e 's/^[[:space:]]\+//' -e 's/inet /Inet /' -e 's/HWaddr /HWaddr:/' \
        -e 's/Bcast:/Bcast: /' -e 's/Mask:/Mask: /' -e 's/addr:/addr: /' |

Xdialog --no-cancel --title "Network status" --logbox - 20 48

rm -f $tmp
