shutdown -h 0
kexec -l /mnt/boot/vmlinuz-* --initrd=/mnt/boot/initrd-* --reuse-cmdline --append
umount /mnt/{dev,proc,sys}
chroot /mnt /bin/sh
mount --bind {,/mnt}/dev; mount --bind {,/mnt}/proc; mount --bind {,/mnt}/sys
TERM=xterm
install
