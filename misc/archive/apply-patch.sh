#!/bin/sh

basedirs="Documentation|architecture|misc|package|scripts|target";
error=0

for patch in "$@"
do
	plevel=1
	for plevelc in 2 0 1
	do
		if egrep -q "^--- ([^/]*/){$plevelc}($basedirs)" $patch; then
		plevel=$plevelc
	fi
	done
	echo
	echo "*** patch -fp$plevel --dry-run < $patch"
	patch -fp$plevel --dry-run < $patch || error=1
done

if [ $error = 1 ]; then
	echo
	echo "*** Dry run returned errors."
	echo
	exit 1
fi

echo
read -p 'Press ENTER to apply the patches or Ctrl-C to abort: '
echo

for patch in "$@"
do
	plevel=1
	for plevelc in 2 0 1
	do
		if egrep -q "^--- ([^/]*/){$plevelc}($basedirs)" $patch; then
			plevel=$plevelc
		fi
	done
	echo "*** patch -fp$plevel < $patch"
	patch -fp$plevel <$patch
	echo
done

