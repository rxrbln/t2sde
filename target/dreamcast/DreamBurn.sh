#!/bin/bash

show_usage() {
cat <<EOT

Usage:
$0 <content> <IP.BIN> [ -cdrw ] [-dev <device>] [-genopt <string>] [-burnopt <string>] [-xa <string>]

Burn boot-able discs for the SEGA Dreamcast console using cdrecord.
mandatory parameters:

    <content>  file or directory containing scrambled executable

    <IP.BIN>   valid IP header conforming to <content>

options:

    -cdrw      burn CD-RW (blank PMA, TOC, Pregap first). Note that
               the Dreamcast cannot read CD-RWs !

    -dev       cdrecord device string. Default is "0,0,0"

    -genopt    additional cdrecord options. Default is ""

    -burnopt   additional cdrecord options for burning (e.g. speed=8 ).
               Default is ""

    -xa        cdrecord option for CD/XA with form 1 sectors with 2048
               bytes per sector. Depending on cdrecord version this is
               -xa or -xa1 (consult the manpage !). Default is "-xa"
EOT
    exit 1
}


##### default values

cdrw=""
dev="0,0,0"
genopt=""
burnopt=""
xa="-xa"

####################


content=$1
ip=$2
shift ; shift

while [ "$1" ] ; do
    case "$1" in
	-cdrw)     cdrw=" blank=minimal" ; shift ;;
	-dev)      dev="$2"      ; shift ; shift ;;
	-genopt)   genopt=" $2"  ; shift ; shift ;;
	-burnopt)  burnopt=" $2" ; shift ; shift ;;
	-xa)       xa="$2"       ; shift ; shift ;;
	
	*)         echo "Unknown option: $1" ; show_usage ;;
    esac
done

[ -e "$content" -a -f "$ip" ] || show_usage;

cdr="cdrecord dev=$dev$genopt"
burnaudio="$cdr$burnopt$cdrw -multi -audio"
info="$cdr -msinfo"
burndata="$cdr$burnopt -multi $xa"

cat <<EOT

cdrecord calls to be executed:

# $burnaudio (FILE)
# $info
# $burndata (FILE)

EOT
echo -n "Proceed ? [Y/n] "
read confirm;

[ -z "$confirm" -o "$confirm" == "y" -o "$confirm" == "Y" ] || exit 0;

audiofile=`mktemp -t audio.raw.XXXXXX`
datafile=`mktemp -t data.raw.XXXXXX`
isofile=`mktemp -t data.iso.XXXXXX`

echo "Creating bogus audio track."
dd if=/dev/zero bs=2352 count=300 of=$audiofile 2>/dev/null
echo
echo

echo "Burning...."
cmd="$burnaudio $audiofile"
echo "$cmd"
eval "$cmd"
echo
echo

echo "Geting multisession status:"
echo "$info"
status=`eval "$info"`
echo "--> $status"
echo
echo

echo "Creating image."
mkisofs -l -C $status -o $isofile $content
echo "Inserting $ip."
( cat $ip ; dd if=$isofile bs=2048 skip=16 ) > $datafile
echo
echo

echo "Burning..."
cmd="$burndata $datafile"
echo "$cmd"
eval "$cmd"
echo
echo
	
echo "Cleaning up."
rm -f $audiofile $isofile $datafile
echo "Done."

