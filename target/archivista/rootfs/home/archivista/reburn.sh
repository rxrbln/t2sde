#!/bin/bash

#
# Burn a archived and burned cd(s) again.
#
#  2007 (c) Archivista GmbH
#       (c) Rijad Nuridini

set -e -x




# range=get_range()
# Asks the User for a range

get_range () {
  local x
  until [ "$x" ]; do
    tx=`Xdialog --stdout --inputbox "$1" 10 50 "$tx"` || exit
    # remove spaces ...
    tx="${tx// /}"
    # remove invalid content
    if echo "$tx" | grep -q "^\([0-9]\+-[0-9]\+\|[0-9]\+\)$" ; then
      x=$tx
    else
      Xdialog --infobox "Range not valid!" 8 28
    fi
  done
  echo $x
}






# archive=get_archive
# Asks the User for an archive

get_archive () {
  local archive
  until [ "$archive" ]; do
    archive=`Xdialog --stdout --inputbox "$1" 0 0 "$archive"` || exit
    archive="${archive// /}"
  done
  echo $archive
}






# max_folder=max_folder($archive,$last_folder,$OUTPUT)
# Checks the latest folder in output folder

max_folder () {
  archive=$1
  last_folder=$2
	OUTPUT=$3
	stopit=0
  last_folder1='ARCH'$(printf "%04d" $last_folder)
	max_folder=`ls $OUTPUT | tail -n 1`
	if [ $last_folder1 = $max_folder ]; then
	  stopit=1
	fi
	echo $stopit
}






# ok=check_folders($archive,$first_folder,$last_folder,$OUTPUT)
# Checks if the folders do exist
# It allways returns the first found folder. (or the last_folder)

check_folders () {
  archive=$1
	first_folder=$2
	last_folder=$3
	OUTPUT=$4
	found=1
  for i in `seq $st_folder $end_folder`;
  do
    FOLDER=$OUTPUT'ARCH'$(printf "%04d" $i)
	  if [ ! -d $FOLDER ]; then
		  found=0
	  fi
	done
	echo $found
}






# size=check_size($archive,$start,$end)
# For All Folder in the range get sizes

check_size () {
  archive=$1
  st_folder=$2
	end_folder=$3
	OUTPUT=$4
  total=0
  for i in `seq $st_folder $end_folder`;
  do
    FOLDER=$OUTPUT'ARCH'$(printf "%04d" $i)
    size=`du -sc $FOLDER | tail -n 1 | cut -f 1`
    total=$(($total+$size))
  done
  echo $total
}






# move_from_export($archive,$start,$end)
# Move All Folders from start till end to OUTPUT

move_from_export () {
  archive="$1"
  st_folder=$2
	end_folder=$3
  OUTPUT="$4"
  EXPORT="$5"
  for i in `seq $st_folder $end_folder`;
  do
    # Create the Full Folder Name
    FOLDER=$EXPORT'ARCH'$(printf "%04d" $i)
		if [ -d $FOLDER ]; then
      mv $FOLDER $OUTPUT
		fi
  done
}






# move_to_export($archive,$start,$end)
# Moves Back to the Export Folder

move_to_export () {
  archive=$1
  st_folder=$2
  end_folder=$3
	OUTPUT=$4
	EXPORT=$5
	for i in `seq $st_folder $end_folder`;
  do
    # Create the Full Folder Name
    FOLDER=$OUTPUT'ARCH'$(printf "%04d" $i)
		if [ -d $FOLDER ]; then
      mv $FOLDER $EXPORT
		fi
  done
}






if [ "$UID" -ne 0 ]; then
  exec gnomesu -p -t "Burn archived folders to CD/DVD" \
  -m "Please enter the system password (root user)^\
in order to burn archived folders again." -c $0
fi

# PATH and co
. /etc/profile

text="Please enter archive"
archive=`get_archive "$text"`

text="Please enter folder range (i.e. 1-4)"
range=`get_range "$text"`

DIR='/home/data/archivista/images/'$archive
EXPORT=$DIR'/export/'
OUTPUT=$DIR'/output/'
if [ ! -d $EXPORT ] ; then
  mkdir $EXPORT
	chown archivista.users $EXPORT
fi

st_folder=${range%-*} # Get everything befor -
end_folder=${range#*-} # Get everything after -
`move_from_export $archive $st_folder $end_folder $OUTPUT $EXPORT`
check=`check_folders $archive $st_folder $end_folder $OUTPUT`
maxfld=`max_folder $archive $end_folder $OUTPUT`
if [ $maxfld -eq 1 ]; then
	Xdialog --stdout --msgbox "Last folder $maxfld can't be burned." 0 0
	exit
fi

if [ $check -eq 1 ]; then
  
	total_size=`check_size $archive $st_folder $end_folder $OUTPUT`

  total_size=$(($total_size/1024))
	
  text="Do you want to burn folder $st_folder-$end_folder with a total of $total_size MBytes?"
  
	Xdialog --stdout --yesno "$text" 0 0 || exit
 
  manual=1
	/home/archivista/wodim.sh $archive "$st_folder-$end_folder" $manual 
 
	# just move the Folders back to where they came from
  move_to_export $archive $st_folder $end_folder $OUTPUT $EXPORT
	
fi

