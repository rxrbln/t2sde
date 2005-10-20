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
        "Enter IP or hostname of slave server:" 0 0 $tslaveip` || exit

        if ! ping -c 1 $tslaveip ; then
                Xdialog --infobox 'Slave not answering (pings)!' 0 0
        else
                slaveip=$tslaveip
        fi
done

# get account name

user=""
until [ "$user" ]; do
	user=`Xdialog --stdout --inputbox \
	      "Name used for the replication account:" 0 0` || exit
done

passwd=""
until [ "$passwd" ]; do
        passwd=`Xdialog --stdout --passwordbox \
                "Password for the replication account:" 0 0` || exit
done

# always on now
#sed -i -e "s/.*log-bin$/log-bin/" \
#       -e "s/.*max-binlog-size.*/max-binlog-size = 300M/" /etc/my.cnf

mysql -uroot -p$PASSWD -hlocalhost <<-EOT
grant replication slave on *.* to '$user'@'$slaveip' identified by '$passwd';
flush privileges;
EOT

mysql -uroot -p$PASSWD -hlocalhost <<-EOT
FLUSH TABLES WITH READ LOCK;
EOT

# enable ssh?
ssh_enabled=0
if ! ps -C sshd ; then
	ssh_enabled=1
	Xdialog --msgbox "Starting remote access (SSH)
for replication." 0 0
	/home/archivista/ssh-enable.sh
fi

Xdialog --ok-label="Continue" \
        --msgbox "Replication can now be performed on the slave. 
Click 'Continue' when the slave is configured and
all database information has been transferred!" 0 0

[ $ssh_enabled = 1 ] && /home/archivista/ssh-disable.sh

mysql -uroot -p$PASSWD -hlocalhost <<-EOT
UNLOCK TABLES;
EOT

