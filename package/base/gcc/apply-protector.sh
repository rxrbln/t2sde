
# only try to apply protector if available
pfile="$( echo "$desc_D" | tr ' ' '\n' | grep protector )"
if [ "$pfile" ] ; then
	echo "Inserting SPP ..."
	tar --use-compress-program=bzip2 \
	  -xf $archdir/${pfile/.gz/.bz2}

	if [ -f protector.dif ] ; then
		patch -p0 < protector.dif
		mv protector.{c,h} gcc/
	elif [ -f gcc_*.dif ] ; then
		patch -p0 < gcc_*.dif
		# the protector.* files are already extracted into gcc/ ...
	else
		abord "Protector patch not found"
	fi
else
	echo "No stack-protector available for $pkg ..."
fi

