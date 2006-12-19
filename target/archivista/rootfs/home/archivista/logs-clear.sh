#!/bin/bash

title="Clear log table"

if [ "$UID" -ne 0 ]; then
  exec gnomesu -p -t "$title" \
	-m "Please enter the system password (root user)^\
in order to remove the entries in the log table right now." -c $0
fi

# PATH and co
. /etc/profile

get_logs_rows ()
{
  echo `/home/cvs/archivista/jobs/logs-clear.pl count`
}

delete_logs ()
{
  echo `/home/cvs/archivista/jobs/logs-clear.pl clear`
}

rows=`get_logs_rows`

if [ $rows -eq 0 ]; then
  mesg="Sorry, there are no rows in the log table!"
  Xdialog --title "$title" --msgbox "$mesg" 8 50
	exit
elif [ $rows -eq -1 ]; then
  mesg="Sorry, there was a database error!"
  Xdialog --title "$title" --msgbox "$mesg" 8 50
	exit
fi

mesg="There are $rows rows in the 'log' table.

Before removing log entries make sure that
all current jobs (ocr, scanning, etc.) are finished.
"

Xdialog --title "$title" --msgbox "$mesg" 0 0 || exit

mesg="ATTENTION: Do you really want to delete $rows (all) rows?"

Xdialog --title "$title" --default-no --yesno "$mesg" 8 50 || exit

del=`delete_logs`

if [ $del -ne 0 ]; then
  mesg="Sorry, there was an error."
else      
  mesg="All rows were deleted."
fi

Xdialog --title "$title" --msgbox "$mesg" 0 0
