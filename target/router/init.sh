#!/bin/bash

mount -n -t proc none /proc
mount -n -t tmpfs none /tmp
cat /proc/mounts > /etc/fstab
cat /proc/mounts > /etc/mtab

ln -sf /proc/kcore      /dev/core
ln -sf /proc/self/fd    /dev/fd
ln -sf fd/0             /dev/stdin
ln -sf fd/1             /dev/stdout
ln -sf fd/2             /dev/stderr

hwscan > /etc/hwscan.sh
sh /etc/hwscan.sh 2> /dev/null

echo
echo "                     *************************************"
echo "                     **        ROCK Router Linux        **"
echo "                     **    http://www.rocklinux.org/    **"
echo "                     *************************************"
echo

for x in vc/{1,2,3,4,5,6} ; do
   ( ( while : ; do agetty -i 38400 $x -n -l /bin/login-shell ; done ) & )
done
                                                                                
exec < /dev/null > /dev/null 2>&1
while : ; do sleep 1 ; done

