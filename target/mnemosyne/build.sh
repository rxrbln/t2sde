pkgloop_action() {
	local rc=
	local desc_M=$( grep -e '^\[M\]' ./package/*/$pkg_name/$pkg_name.desc | cut -d' ' -f2- )
	local desc_P=$( grep -e '^\[P\]' ./package/*/$pkg_name/$pkg_name.desc | cut -d' ' -f2- )

        $cmd_buildpkg ; rc=$?

	admdir="build/${ROCKCFG_ID}/var/adm"

	if [ $ROCKCFG_TRG_MNEMOSYNE_COPYCACHE -eq 1 -a -r $admdir/cache/$pkg_name ]; then
		if grep -q -e '^\[M\] .*Alejandro Mery' -e '^\[P\] O' ./package/*/$pkg_name/$pkg_name.desc; then
			echo_status "mnemosyne: catching cache file."
			cp $admdir/cache/$pkg_name ./package/$pkg_tree/$pkg_name/$pkg_name.cache
		fi
	fi

	if [ -f ./.pause ]; then
		echo_status "mnemosyne: pausing building..."
		rm -f ./.pause
		exit 0
	fi
	return $rc
}

. target/generic/build.sh
