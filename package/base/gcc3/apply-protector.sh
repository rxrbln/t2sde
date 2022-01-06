
# only try to apply protector if present
read x pfile x < <( echo "$3" | grep protector )
if [ "$pfile" ] ; then
	tar --use-compress-program=bzip2 \
	  -xf $1/download/base/$2/${pfile/.gz/.bz2}

	# Patch protector.dif a bit to apply against current gcc-3
	#[ $2 = gcc3 ] && patch -p1 < $1/package/base/$2/protector-hotfix.diff

	# be careful if you enable this, you have to respect $pkg.
	# Set -fstack-protector as default?
	# [ $ROCKCFG_PKG_GCC[23]_STACKPRO = 1 ] && patch -p0 < protectonly.dif

	patch -p0 < protector.dif
	mv protector.{c,h} gcc/
else
	echo "No stack-protector available for $2 ..."
fi

