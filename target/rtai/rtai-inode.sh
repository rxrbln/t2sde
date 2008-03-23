# rtai-inode: RTAI inode creation for UDEV systems, creates /dev/rtf(n)
rm -f /dev/comedi* /dev/rtf* /dev/rtai_shm
for n in ‘seq 0 9‘; do
    rm -f /dev/rtf$n;
    mknod -m 666 $root/dev/rtf$n c 150 $$n;
done ;

# create shared memory inode
mknod -m 666 $root/dev/rtai_shm c 10 254

# create Comedi inodes
for i in ‘seq 0 15‘; do
    rm -f /dev/comedi$i;
    mknod -m 666 /dev/comedi$i c 98 $i ;
done;

# create dev/urandome for Dropbear to function
mknod -m 0644 /dev/random c 1 8
mknod -m 0644 /dev/urandom c 1 9			   