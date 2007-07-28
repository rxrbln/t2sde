#!/bin/bash

doit=1
full=0

[ "$1" == "-dry" ] && doit=0 && shift
[ "$1" == "-full" ] && full=1 && shift

from="$1" ; shift
to="$1" ; shift

if [ -z "$from" ] || [ -z "$to" -a $doit -ne 0 ]; then
	echo "Usage: $0 [ -dry ] from-dir to-dir"
	exit
fi

# include shared code
. ${0%/*}/Global.pm.in
. ${0%/*}/perl-var.in
. ${0%/*}/multi-cpu.in

# include specified configuration values
if [ ! -e $from/config ]; then
	echo "$from/config does not exist"
	exit
fi
. $from/config

[ $doit = 1 ] && cd $to

# passwords
if [ "$update_root_hash" -a $full = 0 ]; then
	echo "root password hash"
	[ $doit = 1 ] &&
	  sed -i "s,root:[^:]*,root:$update_root_hash," etc/shadow 
fi

if [ "$update_archivista_hash" -a $full = 0 ]; then
	echo "archivista password hash"
	[ $doit = 1 ] &&
	  sed -i "s,archivista:[^:]*,archivista:$update_archivista_hash," \
	         etc/shadow
fi

if [ "$update_ftp_hash" ]; then
	echo "ftp password hash"
	[ $doit = 1 ] &&
	  sed -i "s,ftp:[^:]*,ftp:$update_ftp_hash," etc/shadow
fi

# perl class
if [ "$update_root_perl_passwd" -a $full = 0 ]; then
	echo "archivista class password"
	if [ $doit = 1 ]; then
	  sed -i "s/\(.*MYSQL_PWD.* = \).*/\1\"$update_root_perl_passwd\";/" \
	         home/cvs/archivista/apcl/Archivista/Config.pm

	  sed -i "/sub avdb_pwd/ { N ; s/\".*\"/\"$update_root_perl_passwd\"/ }" \
	         home/cvs/archivista/webclient/perl/inc/Global.pm
	fi
fi

# crontab
if [ -f $from/crontab ]; then
	echo "crontab"
	[ $doit = 1 ] && cp -fv $from/crontab etc/
fi

if [ -f $from/cronroot ]; then
	echo "cronroot"
	[ $doit = 1 ] && cp -fv $from/cronroot var/spool/cron/crontabs/root
fi

# database slave mode
if [ "$update_db_master_host" ]; then
	echo "database slave setup"
	if [ $doit = 1 ]; then
		sed -i -e "s/.*server-id.*/server-id = 2/" \
		       -e "s/.*master-host.*$/master-host = $update_db_master_host/" \
		       -e "s/.*master-user.*$/master-user = $update_db_master_user/" \
		       -e "s/.*master-password.*$/master-password = $update_db_master_password/" \
		       etc/my.cnf
	fi
fi

# gnupg key
if [ -e $from/.gnupg ]; then
	echo "encryption keys"
	if [ $doit = 1 ]; then
	  cp -rfv $from/.gnupg home/archivista/
	  chmod 700 home/archivista/.gnupg
	  chmod 600 home/archivista/.gnupg/*
	fi
fi

# ssh key
if [ -e $from/ssh_host_key ]; then
	echo "SSH keys"
	if [ $doit = 1 ]; then
	  cp -fv $from/ssh_*key* etc/ssh/
	  chmod 600 etc/ssh/ssh_*_key
	fi
fi

# ssh enabled
if [ "$update_ssh_enabled" ]; then
	echo "SSH enabled"
	if [ $doit = 1 ]; then
		ln -sf ../init.d/sshd etc/rc.d/rc5.d/S25sshd
		ln -sf ../init.d/sshd etc/rc.d/rc5.d/K75sshd
	fi
fi

# vnc

if [ -e $from/vnc.conf ]; then
	echo "VNC enabled"
	[ $doit = 1 ] && cp -fv $from/vnc.conf etc/
fi

# network
if [ -e $from/network ]; then
	echo "network configuration"
	[ $doit = 1 ] && cp -fv $from/network etc/conf/network
fi

# https
if [ "$update_apache_https" ]; then
	echo "https enabled"
	if [ $doit = 1 ]; then
	  # tweak init script to start with SSL suport
	  sed -i "s/apachectl .*start/apachectl -DSSL -k start/" sbin/init.d/apache

	  # tweak the window manager references to http - menu, keys, startup
	  sed -i 's,http://localhost/,https://localhost/,g' home/archivista/.fluxbox/*

	  cp -rfv $from/https/ssl.{crt,key} etc/opt/apache/
	  chmod 600 etc/opt/apache/ssl.key/*.key
	fi
fi

# cups - this might need adaptions for future CUPS versions ...
if [ "$update_cups_allow" ]; then
	echo "printer configuration (CUPS)"
	if [ $doit = 1 ]; then
	  # insert IP - TODO: share code
	  sed -i "/^<Location \/>/{
n;n;n;n
i Allow From $update_cups_allow

:loop
/^<\/Location>/b end
d; b loop

:end

}" etc/cups/cupsd.conf

	  # configuration and PPDs
	  cp -fv $from/cups/printers.conf etc/cups/
	  cp -fv $from/cups/*.ppd etc/cups/ppd/
	  # enable CUPS at startup
	  ln -sf ../init.d/cups etc/rc.d/rc5.d/S30cups
	  ln -sf ../init.d/cups etc/rc.d/rc5.d/K70cups
	fi
fi

# exim, incoming
if [ "$update_mail_incoming" ]; then
	echo "incoming mail server enabled"
	if [ $doit = 1 ]; then
		sed -i -e 's/^\([^# ]*local_interfaces \)/# \1/' \
		       -e "s|^\(hostlist .*relay_from_hosts = 127.0.0.1\).*|\1 : $update_mail_relay|" \
		    etc/exim/configure
	fi
fi

# admin mail
if [ "$update_mail_to" ]; then
	echo "mail notification address"
	if [ $doit = 1 ]; then
		echo "To=\"$update_mail_to\"" > etc/mail.conf
	fi
fi


# backup
if [ "$update_backup" ]; then
	echo "backup date and time"
	if [ $doit = 1 ]; then
	  sed -i "/\/backup.sh/d" -i etc/crontab
	  echo "$update_backup root /home/archivista/backup.sh" \
	  >> etc/crontab
	fi
fi

# network backup
if [ "$update_net_backup" ]; then
	echo "net-backup config, date and time"
	if [ $doit = 1 ]; then
	  sed -i "/\/net-backup.sh/d" -i etc/crontab
	  echo "$update_net_backup root /home/archivista/net-backup.sh" \
	  >> etc/crontab
	  cp -fv $from/net-backup.conf etc/
	fi
fi

# rsync backup
if [ "$update_rsync_backup" ]; then
	echo "rsync-backup config, date and time"
	if [ $doit = 1 ]; then
		sed -i "/\/rsync-backup.sh/d" -i etc/crontab
		echo "$update_rsync_backup root /home/archivista/rsync-backup.sh" \
		>> etc/crontab
		cp -fv $from/rsync-backup.conf etc/
		mkdir -p root/.ssh
		cp -rv $from/rsync-backup/id_rsa* root/.ssh/
		chmod 700 root/.ssh ; chmod 600 root/.ssh/id_rsa*
	fi
fi

# usb backup
if [ "$update_usb_backup" ]; then
	echo "usb-backup config, date and time"
	if [ $doit = 1 ]; then
	  sed -i "/\/usb-backup.sh/d" -i etc/crontab
	  echo "$update_usb_backup root /home/archivista/usb-backup.sh" \
	  >> etc/crontab
	fi
fi

# ftp
if [ "$update_ftp_enabled" ]; then
	echo "ftp enabled"
	[ $doit = 1 ] &&
          sed -i 's,.*\(ftp[[:blank:]].*\)$,\1,' etc/inetd.conf
fi

# OCR reg key
if [ -e $from/av7.con ]; then
	echo "OCR registration"
	if [ $doit = 1 ]; then
	  cp -fv $from/av7.con home/archivista/.wine/drive_c/Programs/Av5e/
	  chown archivista:users home/archivista/.wine/drive_c/Programs/Av5e/av7.con
	fi
fi


# other, fine grained configuration values
root=$to
if [ "$update_onlyLocalhost" ]; then
	echo "login mask configuration"
	if [ $doit = 1 ]; then
		set_Global.pm_var onlyLocalhost $update_onlyLocalhost
		set_Global.pm_var onlyDefaultDb $update_onlyDefaultDb
		set_Global.pm_string defaultLoginHost $update_defaultLoginHost
		set_Global.pm_string defaultLoginDb $update_defaultLoginDb
		set_Global.pm_string defaultLoginUser $update_defaultLoginUser
	fi
fi

if [ -f $from/av-button.conf ]; then
	echo "scan button state"
	if [ $doit = 1 ]; then
		cp -fv $from/av-button.conf etc/
	fi
fi

if [ "$update_button_host" ]; then
	echo "scan button configuration"
	if [ $doit = 1 ]; then
		set_perl_var '\$val{host1}' $to/home/cvs/archivista/jobs/sane-button.pl \
		             "$update_button_host"
		set_perl_var '\$val{db1}' $to/home/cvs/archivista/jobs/sane-button.pl \
		             "$update_button_db"
		set_perl_var '\$val{user1}' $to/home/cvs/archivista/jobs/sane-button.pl \
		             "$update_button_user"
		set_perl_var '\$val{pw1}' $to/home/cvs/archivista/jobs/sane-button.pl \
		             "$update_button_pw"
	fi
fi

if [ "$update_multi_cpu" -a "$update_multi_cpu" != 0 ]; then
	echo "multi CPU enabled"
	if [ $doit = 1 ]; then
		set_max_cpus $to/boot/grub/menu.lst $update_multi_cpu
	fi
fi
