
# only try to apply protector if available
pfile=`match_source_file -p protector`
if [ "$pfile" ] ; then
	echo "Inserting SPP ..."
	ppatch=`tar -v $taropt $pfile | grep 'dif\$' | head -n 1`

	if [ "$ppatch" -a -f $ppatch ]; then
		[ -f $confdir/protector-adapter.diff ] && \
			patch -p0 $ppatch $confdir/protector-adapter.diff
		patch -p0  < $ppatch
	else
		abort "Protector patch not found"
	fi
	if [ -f protector.c ] ; then
		mv protector.{c,h} gcc/
	fi
else
	echo "No stack-protector available for $pkg ..."
fi

