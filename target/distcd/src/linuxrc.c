/* Copyright (C) 2005 Juergen "George" Sawinski
   Distributed under the License: GPLv2 (or any later version) */

#include <stdio.h>
#include <string.h>
#include <limits.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <sys/mount.h>

#include "cdrom.h"

#ifdef DEBUG
#define dbg(fmt, args...) printf(fmt, ## args)
#else
#define dbg(fmt, args...) struct swallow_semicolon
#endif

int
main(int argc, char **argv) 
{
  int fd;
  char blank[] = "";
  char buf[PATH_MAX+1];
  FILE *f;
  int cd;
  struct stat sbuf;

  /* Init **********************************************************/
  /* mount proc */
  fprintf(stdout, "Mounting /proc..."); fflush(stdout);
  if (mount("proc", "/proc", "proc", MS_MGC_VAL, blank)) {
    perror("mount /proc");
    exit(1);
  }
  fprintf(stdout, " done\n");

  /* Detetecting image *********************************************/
#ifdef USE_CDROM
  cdrom_detect();
#endif

  /*****************************************************************/
  /* FIXME what else??? */

  /* FIXME mount /dev, /proc etc. to new root */

  /* FIXME free ramdisk */
  /* FIXME pivot_root */
  chdir("/");
  
  /* INIT */
  execv("/bin/bash", argv);
  
  /* should never be reached */
  return 1;
}

#ifdef USE_CDROM
#include "cdrom.c"
#endif

