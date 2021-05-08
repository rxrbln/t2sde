umount /mnt/{dev,proc,sys}
chroot /mnt /bin/sh
mount --bind {,/mnt}/dev; mount --bind {,/mnt}/proc; mount --bind {,/mnt}/sys
