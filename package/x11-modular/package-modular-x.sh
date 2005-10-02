#!/bin/bash

curl http://xorg.freedesktop.org/X11R7.0-RC0/everything/ |
     tr \" "\n" | grep "tar.bz2$" |
     sed -e s/.tar.bz2// -e 's/-\([0-9]\)/ \1/' |
while read pkg ver
do
	echo $pkg $ver
	rm -rf package/x11-modular/$pkg
	file=$pkg
	pkg=`echo $pkg | tr A-Z a-z`
	mkdir -p package/x11-modular/$pkg
	cat > package/x11-modular/$pkg/$pkg.desc <<-EOT
[I] A modular X package

[T] A modular X package

[U] http://www.X.org

[A] X.org Foundation {http://www.X.org}
[M] Rene Rebe <rene@t2-project.org>

[C] base/x11

[L] OpenSource
[S] Stable
[V] $ver
[P] X -----5---9 112.600

[O] . package/x11-modular/*/modular-x-conf.in

[D] 0 $file-$ver.tar.bz2 http://xorg.freedesktop.org/X11R7.0-RC0/everything/
EOT
done

