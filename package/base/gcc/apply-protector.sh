
# only try to apply protector if available
pfile="$( echo "$desc_D" | tr ' ' '\n' | grep protector )"
if [ "$pfile" ] ; then
	echo "Inserting SPP ..."
	tar --use-compress-program=bzip2 \
	  -xf $archdir/${pfile/.gz/.bz2}

	if [ -f protector.dif ] ; then
		patch -p0 < protector.dif
	elif [ -f gcc_*.dif ] ; then
		patch -p0 < gcc_*.dif
	else
		abord "Protector patch not found"
	fi
	if [ -f protector.c ] ; then
		mv protector.{c,h} gcc/
	fi
else
	echo "No stack-protector available for $pkg ..."
fi

