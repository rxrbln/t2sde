
if [ "$prefix_auto" = 1 ] ; then
  if [ "$NO_SANITY_CHECK" ] ; then
	prefix=$ROCKCFG_PKG_KDE3_CORE_PREFIX
  else 
	pkgprefix -t arts
	prefix=`pkgprefix prefix arts`
  fi

  set_confopt
fi

# make sure the right qt and kde libs are used
export LD_LIBRARY_PATH="$QTDIR/lib:/$prefix/lib:$LD_LIBRARY_PATH"

# KDE specific configure options
var_append confopt " " "--with-qt-dir=$QTDIR \
                        --with-qt-includes=$QTDIR/include \
                        --with-qt-libraries=$QTDIR/lib"

# some feature and optimization settings ...

if pkginstalled openldap; then
	pkgprefix -t openldap
	var_append confopt " " "--with-ldap=$root/$( pkgprefix openldap )"
fi
var_append confopt " " "--with-xinerama --enable-dnotify"
var_append confopt " " "--enable-final"
[ $arch = x86 ] && var_append confopt " " "--enable-fast-malloc=full"

