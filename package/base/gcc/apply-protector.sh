
pfile=$( echo "$3" | grep protector | tr ' ' '\t' | tr -s '\t' | cut -f2 )

if [ "$pfile" ]
then
	tar --use-compress-program=bzip2 -xf $archdir/${pfile/.gz/.bz2}

	# Patch protector.dif a bit to apply against current gcc-3
	if test -f $1/package/base/gcc/$2/protector-hotfix.diff; then
		patch -p1 < $1/package/base/$2/protector-hotfix.diff
	fi

	# be careful if you enable this, you have to respect $pkg.
	# Set -fstack-protector as default?
	# [ $ROCKCFG_PKG_GCC[23]_STACKPRO = 1 ] && patch -p0 < protectonly.dif

	patch -p0 < protector.dif
	if [ $2 != gcc34 ]; then
		mv protector.{c,h} gcc/
	fi
else
	echo "No stack-protector available for $2 ..."
fi

