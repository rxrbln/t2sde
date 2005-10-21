#!/bin/bash

if [ "$UID" -ne 0 ]; then
	exec gnomesu -p -t "Enable database slave mode" \
	-m "Please enter the system password (root user)^\
in order to enable the database slave mode." \
	-c "/usr/X11/bin/xterm -rv -fa Mono -e $0"
fi

# PATH and co
. /etc/profile

Xdialog --default-no --yesno "Enabling slave mode will erase
the current database!
Are you sure you want to proceed?" 10 38 || exit

# get master ip
until [ "$masterip" ]; do
	tmasterip=`Xdialog --stdout --inputbox \
	"Enter IP or hostname of master server:" 10 38 $tmasterip` || exit

	if ! ping -c 1 $tmasterip ; then
		Xdialog --infobox 'Master not answering (pings)!' 8 28
	else
		export masterip=$tmasterip
	fi
done 

user=""
until [ "$user" ]; do
        user=`Xdialog --stdout --inputbox \
              "Name used for the replication account:" 10 38` || exit
done

passwd=""
until [ "$passwd" ]; do
        passwd=`Xdialog --stdout --passwordbox \
                "Password for the replication account:" 10 38` || exit
done

rc mysql stop

# copy the db and perform other needed tasks on the master
echo "Please enter the master server system (root user) password in order to
copy the initial database:"
rsync -arve ssh --delete --exclude '*-bin.*' --exclude '*.info' \
      --delete-excluded \
      $masterip:/home/data/archivista/mysql \
                /home/data/archivista/
error=$?

if [ $error -ne 0 ]; then
	echo Return code: $error
	Xdialog --msgbox 'Error obtaining initial
database from master!' 8 28
	exit
fi

# configure slave mode
sed -i -e "s/.*server-id.*/server-id = 2/" \
       -e "s/.*master-host.*$/master-host = $masterip/" \
       -e "s/.*master-user.*$/master-user = $user/" \
       -e "s/.*master-password.*$/master-password = $passwd/" /etc/my.cnf

#TODO allow: rc mysql start --skip-slave-start ...
/opt/mysql/bin/mysqld_safe --pid-file=/var/opt/mysql/pid --skip-slave-start &
sleep 2

read log pos < <(tail -n 1 /home/data/archivista/mysql/log-pos)

mysql -uroot -p$PASSWD -hlocalhost <<-EOT
CHANGE MASTER TO
       MASTER_HOST='$masterip',
       MASTER_USER='$user',
       MASTER_PASSWORD='$passwd',
       MASTER_LOG_FILE='$log',
       MASTER_LOG_POS=$pos;
START SLAVE;
EOT

echo "Press enter or close this window."
read in

