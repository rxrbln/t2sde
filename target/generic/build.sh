
# This is the shortest possible target build.sh script. Some targets will
# add code after calling pkgloop() or modify pkgloop's behavior by defining
# a new pkgloop_action() function.
#
pkgloop

echo_header "Finishing build."

grep "^X" config/$config/packages | cut -d ' ' -f 5-6 | \
	sed "s/ /-/" > /tmp/$$-gem-files

echo_status "Searching for missing binary packages ..."
for x in `cat /tmp/$$-gem-files` ; do
   if [ ! -e build/$ROCKCFG_ID/pkgs/$x.* ] ; then
	echo "$x binary package is missing!"
   fi
done

if [ ! $ROCKCFG_PKGFILE_VER = 1 ] ; then
   echo_status "Checking for binary package files with old version ..."

   rm -f invalid-files.lst 2> /dev/null

   for file in `cd build/$ROCKCFG_ID/pkgs/ ; ls * ` ; do
	x=${file/.gem/} ; x=${x/.tar.bz2//}
	if ! grep -q $x /tmp/$$-gem-files ; then
		echo "$file should not be present (now in invalid-files.lst)!"
		echo $file >> invalid-files.lst
	fi
   done
fi

echo_status "Creating package database ..."
admdir="build/${ROCKCFG_ID}/root/var/adm"
create_package_db $admdir > build/${ROCKCFG_ID}/packages.db

echo_status "Creating isofs.txt file .."
cat << EOT > build/${ROCKCFG_ID}/isofs.txt
DISK1	$admdir/cache/			${ROCKCFG_SHORTID}/info/cache/
DISK1	$admdir/cksums/			${ROCKCFG_SHORTID}/info/cksums/
DISK1	$admdir/dependencies/		${ROCKCFG_SHORTID}/info/dependencies/
DISK1	$admdir/descs/			${ROCKCFG_SHORTID}/info/descs/
DISK1	$admdir/flists/			${ROCKCFG_SHORTID}/info/flists/
DISK1	$admdir/md5sums/		${ROCKCFG_SHORTID}/info/md5sums/
DISK1	$admdir/packages/		${ROCKCFG_SHORTID}/info/packages/
EVERY	build/${ROCKCFG_ID}/packages.db	${ROCKCFG_SHORTID}/packages.db
SPLIT	build/${ROCKCFG_ID}/pkgs/	${ROCKCFG_SHORTID}/pkgs/
EOT
