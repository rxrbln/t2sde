#!/bin/bash

if [ "$UID" -ne 0 ]; then
	exec gnomesu -p -t "Enable database master mode" \
	-m "Please enter the system password (root user)^\
in order to enable the database master mode." -c $0
fi

# PATH and co
. /etc/profile

# get slave ip
until [ "$slaveip" ]; do
        tslaveip=`Xdialog --stdout --inputbox \
        "Enter IP or hostname of slave server:" 10 38 $tslaveip` || exit

        if ! ping -c 1 $tslaveip ; then
                Xdialog --infobox 'Slave not answering (pings)!' 8 28
        else
                slaveip=$tslaveip
        fi
done

# get account name

user=""
until [ "$user" ]; do
	user=`Xdialog --stdout --inputbox \
	      "Name used for the replication account:" 10 38` || exit
done

passwd=""
until [ "$passwd" ]; do
        passwd=`Xdialog --stdout --inputbox \
                "Password for the replication account:" 10 38` || exit
done

sed -i -e "s/.*log-bin$/log-bin/" \
       -e "s/.*max-binlog-size.*/max-binlog-size = 300M/" /etc/my.cnf

mysql -uroot -p$PASSWD -hlocalhost <<-EOT
grant replication slave on *.* to '$user'@'$slaveip' identified by '$passwd';
flush privileges;
EOT

rc mysql stop
sleep 2
killall mysqld 2>/dev/null && sleep 2 && killall -9 mysqld 2>/dev/null
rc mysql start

# enable ssh?
ssh_enabled=0
if ! ps -C sshd ; then
	ssh_enabled=1
	/home/archivista/ssh-enable.sh
	Xdialog --msgbox "Remote access (SSH) started
for replication." 8 30
fi

rc mysql stop

Xdialog --msgbox "Replication can now be performed
on the slave." 8 30

[ $ssh_enabled = 1 ] && /home/archivista/ssh-disable.sh

rc mysql start

