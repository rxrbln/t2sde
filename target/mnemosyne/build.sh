pkgloop_action() {
	local rc

        $cmd_buildpkg ; rc=$?

	admdir="build/${ROCKCFG_ID}/var/adm"

	if [ $ROCKCFG_TRG_MNEMOSYNE_COPYCACHE -eq 1 ] && \
	   [[ "$desc_M" == "Alejandro Mery*" ]] && [[ "$desc_P" == "O*" ]]; then
		if [ -r $admdir/cache/$pkg_name ]; then
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
