umount /mnt/target/dev; umount /mnt/target/proc; umount /mnt/target/sys
chroot /mnt/target /bin/sh
mount --bind {,/mnt/target}/dev; mount --bind {,/mnt/target}/proc; mount --bind {,/mnt/target}/sys
