
# only try to apply protector if available
pfile=`match_source_file -p protector`
if [ "$pfile" ] ; then
	echo "Inserting SPP ..."
	tar $taropt $pfile

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

