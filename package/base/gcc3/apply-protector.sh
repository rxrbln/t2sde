
# exclude some version - since we do not have a stack-protector for them
if [ $2 = gccx ] ; then
	echo "No stack-protector available for $2 ..."
else
	read x pfile x < <( echo "$3" | grep protector; )

	tar --use-compress-program=bzip2 \
	  -xf $1/download/base/$2/${pfile/.gz/.bz2}

	# Patch protector.dif a bit to apply against current gcc-3
	#[ $2 = gcc3 ] && patch -p1 < $1/package/base/$2/protector-hotfix.diff

	# Set -fstack-protector as default?
	# [ $ROCKCFG_PKG_GCC[23]_STACKPRO = 1 ] && patch -p0 < protectonly.dif

	patch -p0 < protector.dif
	mv protector.{c,h} gcc/
fi

