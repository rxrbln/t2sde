
build_result="$build_dir/result"

pkgloop_action() {

	# Rebuild command line without '$cmd_maketar'
	#
        cmd_buildpkg="./scripts/Build-Pkg -$stagelevel -cfg $config"
        cmd_buildpkg="$cmd_buildpkg $cmd_root $cmd_prefix $pkg_name"

	# Build package
	#
	$cmd_buildpkg ; rc=$?

	# Copy *.cache file
	#
	if [ -f "$build_root/var/adm/cache/$pkg_name" ] ; then
		dir="$build_result/package/$pkg_tree/$pkg_name" ; mkdir -p $dir
		cp $build_root/var/adm/cache/$pkg_name $dir/$pkg_name.cache
	fi

	return $rc
}

pkgloop

echo_header "Finishing build."

echo_status "Creating new dependency database .."
mkdir -p "$build_result/scripts"
./scripts/Create-DepDB -cachedir "$build_result/package" \
	> "$build_result/scripts/dep_db.txt" 2> /dev/null

echo_status "Copying error logs and rock-debug data."
mkdir -p $build_result/{errors,rock-debug,dep-debug}
cp $build_root/var/adm/rock-debug/* $build_result/rock-debug/
cp $build_root/var/adm/dep-debug/* $build_result/dep-debug/
cp $build_root/var/adm/logs/*.err $build_result/errors/

echo_status "Creating package database ..."
admdir="build/${ROCKCFG_ID}/root/var/adm"
create_package_db $admdir build/${ROCKCFG_ID}/pkgs \
                  build/${ROCKCFG_ID}/packages.db

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

echo_header "Reference build finished."

cat <<- EOT > build/${ROCKCFG_ID}/result/copy-cache.sh
	#!/bin/sh
	cd $base/build/${ROCKCFG_ID}/result
	find package -type f | while read fn
	do [ -f ../../../\${fn%.cache}.desc ] && cp -v \$fn ../../../\$fn; done
	cd ../../..; ./scripts/Create-DepDB > scripts/dep_db.txt
EOT
chmod +x build/${ROCKCFG_ID}/result/copy-cache.sh

echo_status "Results are stored in the directory"
echo_status "build/$ROCKCFG_ID/result/."

