#!/bin/bash

if [ "$UID" -ne 0 ]; then
	exec gnomesu -t "Enable database slave mode" \
	-m "Please enter the system password (root user)^\
in order to enable the database slave mode." \
	-c "/usr/X11/bin/xterm -rv -fa Mono -e $0"
fi

# PATH and co
. /etc/profile

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

Xdialog --yesno "Enabling slave mode will erase
the current database!
Are you sure you want to proceed?" 10 38 || exit

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

rc mysql stop
sleep 2
killall mysqld
sleep 2
killall -9 mysqld

# copy the db and perform other needed tasks on the master
echo "Please enter the master server system (root user) password in order to
copy the initial database:"
rsync -arve ssh --delete $masterip:/home/data/archivista/mysql \
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
       -e "s/.*log-bin$/log-bin/" \
       -e "s/.*master-host.*$/master-host = $masterip/" \
       -e "s/.*master-user.*$/master-user = $user/" \
       -e "s/.*master-password.*$/master-password = $passwd/" /etc/my.cnf

rc mysql start

echo "Press enter or close this window."
read in

