/* Copyright (C) 2005 Juergen "George" Sawinski
   Distributed under the terms of the GPL,
   see LICENSE file of distribution. */
#include <limits.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <sys/mount.h>
#include <stdio.h>

int cdrom_detect() {
  FILE *f;
  char buf[PATH_MAX+1];
  const char *blank = "";
  struct stat sbuf;

#ifdef USE_DEVFS
  int cd;

  cd = 0;
  
  fprintf(stdout, "Detecting CD-ROM...\n");
  do {
    snprintf(buf, PATH_MAX, "/dev/cdroms/cdrom%d", cd);

    if (stat(buf, &sbuf)) {
      perror("no CD-ROM found");
      return 1;
    }
    else {
      fprintf(stdout, "  cdrom%d...", cd); fflush(stdout);
      if (!mount(buf, "/mnt/source", "iso9660", MS_MGC_VAL+MS_RDONLY, blank)) {
	/* check for boot/vmlinuz */
	if (!stat("/mnt/source/boot/vmlinuz", &sbuf)) {
	  fprintf(stdout, " found\n");
	  return 0;
	}
	else {
	  umount(buf);
	  fprintf(stdout, " no\n");
	}
      }
      else {
	fprintf(stdout, " failed\n");
      }
    }
  } while (++cd);
#else
  f = fopen("/proc/sys/dev/cdrom/info", "r");

  if (!f) {
    perror("getting cdrom info");
    return 1;
  }

  while (!feof(f) && fgets(buf, PATH_MAX, f)) {
    if (strstr(buf, "drive name:") == buf) { /* sort out names */
      char *ptr = buf+12;

      while (*ptr) {
	char *drv;

	while (*ptr && ((*ptr == ' ') || (*ptr == '\t'))) ptr++;
	drv = ptr;
	while (*ptr && !((*ptr == ' ') || (*ptr == '\t') || (*ptr == '\n'))) ptr++;
	if (*ptr) *ptr++ = 0;
	
	fprintf(stdout, "  %s..", drv);
	/* FIXME: open cdrom and check for distcd stamp on CD */
      };
    }
  }
  fclose(f);
#endif 
  
  return -1;
}
