
# only try to apply protector if available
pfile=$( echo "$3" | grep protector | tr ' ' '\t' | tr -s '\t' | cut -f2 )
if [ "$pfile" ] ; then
	tar --use-compress-program=bzip2 \
	  -xf $archdir/${pfile/.gz/.bz2}

	# be careful if you enable this, you have to respect $pkg.
	# Set -fstack-protector as default?
	# [ $ROCKCFG_PKG_GCC[23]_STACKPRO = 1 ] && patch -p0 < protectonly.dif

	if [ -f protector.dif ] ; then
		patch -p0 < protector.dif
		mv protector.{c,h} gcc/
	elif [ -f gcc_*.dif ] ; then
		patch -p0 < gcc_*.dif
		# the protector.* files already extract into gcc/ ...
	else
		abord "Protector patch not found"
	fi
else
	echo "No stack-protector available for $2 ..."
fi

