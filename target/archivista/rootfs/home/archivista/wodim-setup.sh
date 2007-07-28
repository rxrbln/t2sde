#!/bin/bash

if [ "$UID" -ne 0 ]; then
	exec gnomesu -t "Setup backup" \
	-m "Please enter the system password (root user)^\
in order to setup the the optical disc archiving." -c $0
fi

# PATH and co
. /etc/profile

. ${0%/*}/wodim-setup.in


# read config if existing
[ -e /etc/wodim.conf ] && . /etc/wodim.conf
[ "$copies" ] || copies=1
[ "$format" ] || format='CD'
[ "$speed" ] || speed=1

# get requested format
cdonoff='off'
dvdonoff='off'
none='off'
case $format in
	CD) cdonoff='on' ;;
	DVD) dvdonoff='on' ;;
	NONE) none='on' ;;
esac

format=`Xdialog --title "Optical disc archiving" --stdout --no-tags --separator ' ' \
                --radiolist  "Format allowed for archiving:" 0 0 4 \
                'CD' 'CD' $cdonoff  'DVD' 'DVD' $dvdonoff 'NONE' 'NONE' $none` || exit

if [ $format == 'NONE' ] ;
then
  rm /etc/wodim.conf
  exit
fi

# get no. of writers
copies=`Xdialog --stdout --title "Optical disc archiving" \
        --spinbox "Number of optical disc copies to
be burned on different writers." 0 0 1 9 $copies "# of writer"` || exit

# get speed
speed=`wodim_speed $speed`

echo "format=\"$format\"
copies=\"$copies\"
speed=\"$speed\"" > /etc/wodim.conf
