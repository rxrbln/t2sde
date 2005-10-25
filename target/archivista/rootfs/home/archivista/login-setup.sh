#!/bin/bash

# Functions to get and set default values in Perl code.
#
# Copyright (C) 2005 Archivista GmbH
# Copyright (C) 2005 Rene Rebe

if [ "$UID" -ne 0 ]; then
	exec gnomesu -t "Setup backup" \
	     -m "Please enter the system password (root user)^\
in order to configure the web client login." -c $0
fi

# PATH and co


. /etc/profile

get_Global.pm_string ()
{
	sed -n "/sub $1/ { N ; s/.*\"\(.*\)\".*/\1/p }" \
	    /home/cvs/archivista/webclient/perl/inc/Global.pm
}

get_Global.pm_var ()
{
        sed -n "/sub $1/ { N ; s/.*return \(.*\);$/\1/p }" \
            /home/cvs/archivista/webclient/perl/inc/Global.pm
}

set_Global.pm_string ()
{
	sed -i "/sub $1/ { N ; s/\".*\"/\"$2\"/ }" \
	    /home/cvs/archivista/webclient/perl/inc/Global.pm
}

set_Global.pm_var ()
{
	sed -i "/sub $1/ { N ; s/return .*/return $2;/ }" \
	    /home/cvs/archivista/webclient/perl/inc/Global.pm
}



onlyLocalhost=`get_Global.pm_var onlyLocalhost`
onlyDefaultDb=`get_Global.pm_var onlyDefaultDb`
defaultLoginHost=`get_Global.pm_string defaultLoginHost`
defaultLoginDb=`get_Global.pm_string defaultLoginDb`
defaultLoginUser=`get_Global.pm_string defaultLoginUser`

if [ $onlyLocalhost -ne 0 ]; then y='' ; else y='--default-no'; fi
if Xdialog $y --yesno "Allow local access only?" 0 0; then
onlyLocalhost=1; else onlyLocalhost=0; fi

if [ $onlyDefaultDb -ne 0 ]; then y='' ; else y='--default-no'; fi
if Xdialog $y --yesno "Allow default database only?" 0 0; then
onlyDefaultDb=1; else onlyDefaultDb=0; fi

defaultLoginHost=`Xdialog --stdout --inputbox "Default host:" 0 0 \
                  $defaultLoginHost`
defaultLoginDb=`Xdialog --stdout --inputbox "Default database:" 0 0 \
                $defaultLoginDb`
defaultLoginUser=`Xdialog --stdout --inputbox "Default user:" 0 0 \
                  $defaultLoginUser`

set_Global.pm_var onlyLocalhost $onlyLocalhost
set_Global.pm_var onlyDefaultDb $onlyDefaultDb
set_Global.pm_string defaultLoginHost $defaultLoginHost
set_Global.pm_string defaultLoginDb $defaultLoginDb
set_Global.pm_string defaultLoginUser $defaultLoginUser

