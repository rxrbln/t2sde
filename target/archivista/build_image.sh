#!/bin/bash

# this is a prelemninary hack just because the archivsta stuff is not
# available in nicer pieces so far
inject_archivista()
{
	pushd .
	# cvs code
	cd $imagelocation/home
	tar xvfz $base/target/$target/cvs.tar.gz

	# configuration
	cd cvs ; patch -p1 < $base/target/$target/config.patch ; cd ..
	
        # set the correct permissions after patching the files
	chgrp -R 80   cvs
	chmod -R o-rx cvs

	# example db
	cd $imagelocation/home/data/archivista
	tar xvfz $base/target/$target/mysql.tar.gz

	# firefox junk
	cd $imagelocation/home/archivista
	tar xvfz $base/target/$target/firefox.tar.gz
	# wine config and archivista "rich-client" installation
	tar xvfz $base/target/$target/wine-archivista.tar.gz

        # copy the manual to /home/archivista
        cp $imagelocation/home/cvs/archivista/webclient/www/*.pdf . 
        chown 500:100 *.pdf

	# make sure the scripts can not be modified by the user
	chown 0:0 *.sh

	# inject versions we do not have immediate control over
	sed -i "s/^\(title.*label.*\)/\1 - $build_date/" $imagelocation/etc/stone.d/mod_grub.sh
	sed -i "s/^\(T2.*\)/\1 - $build_date/" $imagelocation/etc/VERSION

	popd
}

inject_hook=inject_archivista

. $base/target/livecd/build_image.sh

