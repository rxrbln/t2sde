#!/bin/bash

echo "Trying to autodetect hardware..."

hwscan >/tmp/hardware

if [ `grep -c '^# ' /tmp/hardware` -gt 0 ] ; then
	echo 'Found the following:'
	grep '^# ' /tmp/hardware | sed 's,^# ,- ,g'
	echo 'Now trying to initialise them...'
	. /tmp/hardware
fi

if [ ! -e /dev/sound/dsp ] ; then
	echo 'EEP! We have no sound!'
	echo 'You can switch to another console with -<Alt>- + -<F2>- to try'
	echo 'and load a sound-module by hand.'
	echo
	echo 'Press -<Enter>- when done to continue ...'
	read
fi

exit 0
