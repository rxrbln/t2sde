#include <stdio.h>
#include <string.h>
#include <sys/mount.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <errno.h>

int main(int argc, char **argv)
{
	int c, f, rc=0;

	if (argc == 1) {
		fprintf(stderr,"Usage: %s /dev/rd/initrd "
			       "[ /dev/rd/12 [ .. ] ]\n", argv[0]);
		return 1;
	}

	for (c=1; c < argc; c++) {  
		if ((f=open(argv[c], O_RDWR)) == -1) {
			fprintf(stderr, "freeramdisk: cannot open %s: %s\n",
			                argv[c], strerror(errno));
			rc++;
		} else {
			ioctl(f, BLKFLSBUF);
			close(f);
		}
	}
	return rc;
}

