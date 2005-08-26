#!/bin/bash

if [ "$UID" -ne 0 ]; then
	exec gnomesu -t "Database slave mode" \
	-m "Please enter the system password (root user)^\
in order to bring the database into slave mode." \
	-c "/usr/X11/bin/xterm -fa Mono -e $0"
fi

# PATH and co
. /etc/profile

# get master ip
until [ "$masterip" ]; do
	tmasterip=`Xdialog --stdout --inputbox \
	"Enter IP or hostname of master server:" 10 38 $tmasterip`

	if ! ping -c 1 $tmasterip ; then
		Xdialog --infobox 'Master not answering (pings)!' 8 28
	else
		export masterip=$tmasterip
	fi
done 

rc mysql stop

# copy the db and perform other needed tasks on the master
echo "Please enter the master server system (root user) password in order to
copy the initial database:"
rsync -arve ssh $masterip:/home/data/archivista/mysql \
                          /home/data/archivista/mysql
echo Return code: $?

if [ $? -ne 0 ]; then
	Xdialog --infobox 'Error obtaining initial database from master!' 8 28
	exit
fi

# bring into slave mode
sed -i -e "s/.*server-id.*/server-id = 2/" \
       -e "s/.*log-bin$/log-bin/" /etc/my.cnf

rc mysql start

echo "Press enter or close the window."
read in

