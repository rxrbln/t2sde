#!/bin/sh

export PATH="/sbin:/bin:/usr/sbin:/usr/bin"
if type -p gzip > /dev/null ; then
	umount /old_root ; rmdir /old_root
else
	PATH="$PATH:/old_root/bin"
	for x in /old_root/* ; do
		rmdir $x 2> /dev/null || rm -f $x 2> /dev/null
	done
fi
grep -v "^rootfs " /proc/mounts > /etc/mtab
freeramdisk /dev/rd/* 2> /dev/null

mkdir -p /lib/modules/$( uname -r )
echo -n >> /lib/modules/$( uname -r )/modules.dep

cd /dev ; rm -f fd
ln -sf /proc/kcore      core
ln -sf /proc/self/fd    fd
ln -sf fd/0             stdin
ln -sf fd/1             stdout
ln -sf fd/2             stderr
cd /

echo
echo '  ******************************************************************'
echo '  *         Welcome to the ROCK Linux 2nd stage boot disk.         *'
echo '  ******************************************************************'
echo
echo 'This is a small linux distribution, loaded into your PCs memory. It has'
echo 'everything needed to install ROCK Linux, restore an old installation or'
echo 'perform some administrative tasks.'

for x in /etc/setup-*.sh /setup/setup.sh ; do
   if [ -f "$x" ] ; then
      echo ; echo "Running $x ..." ; sh $x
      echo "Setup script $x finished."
   fi
done

echo
echo "Enter the names of all terminal devices (e.g. 'vc/1' or 'tts/0')."
echo -n "An empty text stands for vc/1 - vc/6: "  ;  read ttydevs
[ -z "$ttydevs" ] && ttydevs="vc/1 vc/2 vc/3 vc/4 vc/5 vc/6"

echo
echo 'Just type "stone" now if you want to make a normal installation of a ROCK'
echo -n 'Linux build '
if type -p dialog > /dev/null ; then
	echo '(or type "stone -text" if you prefer non-dialog based menus).'
else
	echo '(only the text interface is available).'
fi

echo -e '#!/bin/sh\ncd ; exec /bin/sh --login' > /sbin/login-shell
chmod +x /sbin/login-shell

for x in $ttydevs ; do
   ( ( while : ; do agetty -i 38400 $x -n -l /sbin/login-shell ; done ) & )
done

exec < /dev/null > /dev/null 2>&1
while : ; do sleep 1 ; done

