#!/bin/bash
# Skript to rescan SCSI bus, using the 
# scsi add-single-device mechanism
# (w) 1998-03-19 Kurt Garloff <kurt@garloff.de> (c) GNU GPL
# (w) 2003-07-16 Kurt Garloff <garloff@suse.de> (c) GNU GPL
# $Id: rescan-scsi-bus.sh,v 1.15 2004/05/08 14:47:13 garloff Exp $

setcolor ()
{
  red="\e[0;31m"
  green="\e[0;32m"
  yellow="\e[0;33m"
  norm="\e[0;0m"
}

unsetcolor () 
{
  red=""; green=""
  yellow=""; norm=""
}

# Return hosts. sysfs must be mounted
findhosts_26 ()
{
  hosts=
  if ! ls /sys/class/scsi_host/host* >/dev/null 2>&1; then
    echo "No SCSI host adapters found in sysfs"
    exit 1;
    #hosts=" 0"
    #return
  fi 
  for hostdir in /sys/class/scsi_host/host*; do
    hostno=${hostdir#/sys/class/scsi_host/host}
    hostname=`cat $hostdir/proc_name`
    hosts="$hosts $hostno"
    echo "Host adapter $hostno ($hostname) found."
  done  
}

# Return hosts. /proc/scsi/HOSTADAPTER/? must exist
findhosts ()
{
  hosts=
  for driverdir in /proc/scsi/*; do
    driver=${driverdir#/proc/scsi/}
    if test $driver = scsi -o $driver = sg -o $driver = dummy -o $driver = device_info; then continue; fi
    for hostdir in $driverdir/*; do
      name=${hostdir#/proc/scsi/*/}
      if test $name = add_map -o $name = map -o $name = mod_parm; then continue; fi
      num=$name
      driverinfo=$driver
      if test -r $hostdir/status; then
	num=$(printf '%d\n' `sed -n 's/SCSI host number://p' $hostdir/status`)
	driverinfo="$driver:$name"
      fi
      hosts="$hosts $num"
      echo "Host adapter $num ($driverinfo) found."
    done
  done
}

# Test if SCSI device $host $channen $id $lun exists
# Outputs description from /proc/scsi/scsi, returns new
testexist ()
{
  grepstr="scsi$host Channel: 0*$channel Id: 0*$id Lun: 0*$lun"
  new=`cat /proc/scsi/scsi | grep -e"$grepstr"`
  if test ! -z "$new"; then
    cat /proc/scsi/scsi | grep -e"$grepstr"
    cat /proc/scsi/scsi | grep -A2 -e"$grepstr" | tail -n2 | pr -o4 -l1
  fi
}

# Perform search (scan $host)
dosearch ()
{
  for channel in $channelsearch; do
    for id in $idsearch; do
      for lun in $lunsearch; do
        new=
	devnr="$host $channel $id $lun"
	echo "Scanning for device $devnr ..."
	printf "${yellow}OLD: $norm"
	testexist
	if test ! -z "$remove" -a ! -z "$new"; then
	  # Device exists and we're in remove mode, so remove and readd
	  echo "scsi remove-single-device $devnr" >/proc/scsi/scsi
	  echo "scsi add-single-device $devnr" >/proc/scsi/scsi
	  printf "\r\x1b[A\x1b[A\x1b[A${yellow}OLD: $norm"
	  testexist
	  if test -z "$new"; then 
	    printf "\r${red}DEL: $norm\r\n\n\n\n"; let rmvd+=1; 
          fi
	fi
	if test -z "$new"; then
	  # Device does not exist, try to add
	  printf "\r${green}NEW: $norm"
	  echo "scsi add-single-device $devnr" >/proc/scsi/scsi
	  testexist
	  if test -z "$new"; then
	    # Device not present
	    printf "\r\x1b[A";
  	    # Optimization: if lun==0, stop here (only if in non-remove mode)
	    if test $lun = 0 -a -z "$remove" -a $optscan = 1; then 
	      break;
	    fi  
	  else 
	    let found+=1; 
	  fi
	fi
      done
    done
  done
}
 
# main
if test @$1 = @--help -o @$1 = @-h -o @$1 = @-?; then
    echo "Usage: rescan-scsi-bus.sh [options] [host [host ...]]"
    echo "Options:"
    echo " -l activates scanning for LUNs 0-7    [default: 0]"
    echo " -w scan for target device IDs 0 .. 15 [default: 0-7]"
    echo " -c enables scanning of channels 0 1   [default: 0]"
    echo " -r enables removing of devices        [default: disabled]"
    echo "--remove:        same as -r"
    echo "--nooptscan:     don't stop looking for LUNs is 0 is not found"
    echo "--color:         use coloured prefixes OLD/NEW/DEL"
    echo "--hosts=LIST:    Scan only host(s) in LIST"
    echo "--channels=LIST: Scan only channel(s) in LIST"
    echo "--ids=LIST:      Scan only target ID(s) in LIST"
    echo "--luns=LIST:     Scan only lun(s) in LIST"  
    echo " Host numbers may thus be specified either directly on cmd line (deprecated) or"
    echo " or with the --hosts=LIST parameter (recommended)."
    echo "LIST: A[-B][,C[-D]]... is a comma separated list of single values and ranges"
    echo " (No spaces allowed.)"
    exit 0
fi

expandlist ()
{
    list=$1
    result=""
    first=${list%%,*}
    rest=${list#*,}
    while test ! -z "$first"; do 
	beg=${first%%-*};
	if test "$beg" = "$first"; then
	    result="$result $beg";
    	else
    	    end=${first#*-}
	    result="$result `seq $beg $end`"
	fi
	test "$rest" = "$first" && rest=""
	first=${rest%%,*}
	rest=${rest#*,}
    done
    echo $result
}

if test ! -d /proc/scsi/; then
  echo "Error: SCSI subsystem not active"
  exit 1
fi	

# defaults
unsetcolor
lunsearch="0"
idsearch=`seq 0 7`
channelsearch="0"
remove=""
optscan=1
if test -d /sys/class/scsi_host; then 
  findhosts_26
else  
  findhosts
fi  

# Scan options
opt="$1"
while test ! -z "$opt" -a -z "${opt##-*}"; do
  opt=${opt#-}
  case "$opt" in
    l) lunsearch=`seq 0 7` ;;
    w) idsearch=`seq 0 15` ;;
    c) channelsearch="0 1" ;;
    r) remove=1 ;;
    -remove)      remove=1 ;;
    -hosts=*)     arg=${opt#-hosts=};   hosts=`expandlist $arg` ;;
    -channels=*)  arg=${opt#-channels=};channelsearch=`expandlist $arg` ;; 
    -ids=*)   arg=${opt#-ids=};         idsearch=`expandlist $arg` ;; 
    -luns=*)  arg=${opt#-luns=};        lunsearch=`expandlist $arg` ;; 
    -color) setcolor ;;
    -nooptscan) optscan=0 ;;
    *) echo "Unknown option -$opt !" ;;
  esac
  shift
  opt="$1"
done    

# Hosts given ?
if test "@$1" != "@"; then 
  hosts=$*; 
fi

echo "Scanning hosts $hosts channels $channelsearch for "
echo " SCSI target IDs " $idsearch ", LUNs " $lunsearch
test -z "$remove" || echo " and remove devices that have disappeared"
declare -i found=0
declare -i rmvd=0
for host in $hosts; do 
  dosearch; 
done
echo "$found new device(s) found.               "
echo "$rmvd device(s) removed.                 "

cat /proc/scsi/scsi | Xdialog --no-cancel --log - 20 60

