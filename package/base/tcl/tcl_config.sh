# tcl_fixdoc $pkg -- documentation (man pages) fixes (common amoung tcl related packages)  
tcl_fixdoc() {
	[ -f Makefile.in ] \
		&& sed -i "s,\(MAN[13N]_INSTALL_DIR)\)/\$\$i,\\1/\$\${i}$1,g" \
			Makefile.in
	[ -f mkLinks ] \
		&& sed -i "s,\([.][13n]\),\\1$1,g" \
			mkLinks
	return 0
}

# tcl_libver $ver -- converts version into major.minor format
tcl_libver() {
	echo $1 | cut -d . -f 1-2
}

# tcl_prepare_source pkg -- unpacks source needed to build derived tcl packages
tcl_prepare_source() { 
	while [ "$1" ]; do
		pushd ..
			local derpkg=$1 derver=`tcl_pkgversion $1` ; shift

			tar $taropt $base/download/mirror/${derpkg:0:1}/$derpkg$derver?src.*bz2

			ln -svf $derpkg$derver $derpkg`tcl_libver $derver`

			cd $derpkg$derver ; [ -d unix ] && cd unix
			./configure --enable-shared
		popd
	done
} 

# tcl_pkgversoin pkg -- grep the version from 'pkg'
#FIXME is there maybe a function in scripts/functions for this?
tcl_pkgversion() {
	egrep '[[](V|VER|VERSION)[]]' $base/package/*/$1/$1.desc | sed 's,[^]]*[]],,' \
		| tr '\t' ' ' | tr -s ' ' | sed -e 's,^[ ]*,,; s,[ ]*$,,;' 
}

# common hooks and confopts for tcl derived packages
hook_add preconf 9 "tcl_fixdoc $pkg" 

extraconfopt="--enable-shared" 
