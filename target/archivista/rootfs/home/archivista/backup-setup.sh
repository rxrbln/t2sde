#!/bin/bash

if [ "$UID" -ne 0 ]; then
	exec gnomesu -t "Setup backup" \
	-m "Please enter the system password (root user)^\
in order to setup the backup." -c $0
fi

# PATH and co
. /etc/profile

# read previous settings
line=`grep "archivista.*backup.sh" /etc/crontab`
tdays=`echo "$line" | cut -d ' ' -f 5`
ttime=`echo "$line" | cut -d ' ' -f 2`

[ "$tdays" ] || tdays="2-6"
[ "$ttime" ] || ttime="2"

until [ "$days" ]; do
	tdays=`Xdialog --stdout --inputbox "Days the backup should be run on.
Allowed are ranges from 1 (Monday) to
7 (Sunday) (e.g. 2-6) and 0 to disable the backup:" 10 40 "$tdays"` || exit
	# remove spaces ...
        tdays="${tdays// /}"
        # remove invalid content
        if echo "$tdays" | grep -q "^\([1-7]\+-[1-7]\+\|[0-7]\+\)$" ; then
		days=$tdays
	else
		Xdialog --infobox "Range not valid!" 8 28
	fi
done

# disable?
if [ "$tdays" = 0 ]; then
	# remove previous line ...
	sed -i "/archivista.*backup.sh/d" /etc/crontab
	rc cron restart
	exit
fi

until [ "$time" ]; do
	ttime=`Xdialog --stdout --inputbox "Time the backup should be run on
the specified days:" 10 40 "$ttime"` || exit
	if [ $ttime -gt 0 -a $ttime -le 24 ]; then
		time=$ttime
	else
		Xdialog --infobox "Time not valid!" 8 28
	fi
done

#remove previous line and add new entry ...
sed -i "/archivista.*backup.sh/d" /etc/crontab
echo "0 $time * * $days root /home/archivista/backup.sh" >> /etc/crontab
rc cron restart

