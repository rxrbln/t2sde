#!patch

--- mod_grub.sh	2005-07-13 00:43:05.000000000 +0000
+++ mod_grub.sh	2005-07-22 07:04:01.000000000 +0000
@@ -20,9 +20,9 @@
 	for x in `(cd /boot/ ; ls vmlinuz_* ) | sort -r` ; do
 		ver=${x/vmlinuz_/}
 		if [ $first = 1 ] ; then
-			label=linux ; first=0
+			label="Archivista" ; first=0
 		else
-			label=linux-$ver
+			label="Archivista (Kernel: $ver)"
 		fi
 
 		cat << EOT
@@ -84,6 +84,11 @@
 timeout 8
 default 0
 fallback 1
+
+foreground  = 000000
+background  = FFFFFF
+splashimage $bootdrive$bootpath/t2.xpm.gz
+
 EOT
 	create_kernel_list >> /boot/grub/menu.lst
 
@@ -89,7 +89,7 @@
 
 	[ -f /boot/memtest86.bin ] && cat << EOT >> /boot/grub/menu.lst
 
-title  MemTest86 (memory tester)
+title  MemTest86 (system memory tester)
 kernel $bootdrive$bootpath/memtest86.bin
 EOT
 
