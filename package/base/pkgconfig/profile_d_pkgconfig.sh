# set the PKG_CONFIG_PATH variable
#
export PKG_CONFIG_PATH=""
for x in {/usr,/opt}{,/*}/{share,lib?*,lib}/pkgconfig $HOME/lib{?*,}/pkgconfig ; do
	[ -d $x ] && PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$x"
done
