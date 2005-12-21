#!/bin/bash

. /etc/profile

tmp=`mktemp`

cron_status ()
{
	read m h x x days junk < <(grep "$1" /etc/crontab)

	if [ "$h" -a "$m" ]; then
		[[ $m = [0-9] ]] && m=0$m
		echo "$2 enabled at $h:$m o'clock for days $days"
	else
		echo "$2 not enabled"
	fi
}

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
	echo

	if grep -q DSSL /sbin/init.d/apache; then
		echo "Web server https (SSL) enabled"
	else
		echo "Web server https (SSL) disabled"
	fi

	if grep -q '^ftp' /etc/inetd.conf; then
		echo "FTP server enabled"
	else
		echo "FTP server disabled"
	fi

	if grep -q '^# *local_interface' /etc/exim/configure; then
		echo "Incomming mail server enabled"
	else
		echo "Incomming mail server disabled"
	fi
	echo

	read junk junk id < <(grep '^server-id' /etc/my.cnf)
	case $id in
	1) 
	   if grep -q '^log-bin' /etc/my.cnf; then
		echo "Database in master mode"
	   else
		echo "Database in normal mode"
	   fi
	   ;;
	2) echo "Database in slave mode" ;;
	esac
	echo

	if [ -e /etc/rc.d/rc5.d/S*cups ]; then
		echo "PDF priting enabled"
		# TODO: Maybe parse cups config for allowed IP ranges ...
	else
		echo "PDF printing disabled"
	fi
	echo

	if ps -C sshd >/dev/null; then
		echo "Remote access (SSH) active"
	else
		echo "Remote access (SSH) not active"
	fi

	if ps -C x11vnc >/dev/null; then
		echo "Graphical remote access (VNC) active"
	else
		echo "Graphical remote access (VNC) not active"
	fi
	echo

	cron_status "/backup.sh" "Tape Backup"
	cron_status "/net-backup.sh" "Network Backup"
	cron_status "/usb-backup.sh" "USB hard-disk Backup"
	echo

	cat /etc/VERSION
) | sed -e 's/^[[:space:]]\+//' -e 's/inet /Inet /' -e 's/HWaddr /HWaddr:/' \
        -e 's/Bcast:/Bcast: /' -e 's/Mask:/Mask: /' -e 's/addr:/addr: /' |

Xdialog --no-cancel --title "System status" --logbox - 35 45

rm -f $tmp
