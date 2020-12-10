umount /mnt/target/{dev,proc,sys}
chroot /mnt/target /bin/sh
mount --bind {,/mnt/target}/dev; mount --bind {,/mnt/target}/proc; mount --bind {,/mnt/target}/sys
