/* simple program to insert a md5sum into application data area of */
/* an iso9660 image                                                */
/* Copyright 2001 Red Hat, Inc.                                    */
/* Michael Fulbright msf@redhat.com                                */

#include <stdio.h>
#include <stdlib.h>
#include <popt.h>

#include "md5.h"
#include "libimplantisomd5.h"


static void usage(void) {
    fprintf(stderr, "implantisomd5:         implantisomd5 [--force] [--supported] <isofilename>\n");
    exit(1);
}


int main(int argc, char **argv) {
    int rc;
    char *errstr;
    const char **args;

    int forceit=0;
    int supported=0;
    int help=0;

    poptContext optCon;
    struct poptOption options[] = {
	{ "force", 'f', POPT_ARG_NONE, &forceit, 0 },
	{ "supported-iso", 'S', POPT_ARG_NONE, &supported, 0 },
	{ "help", 'h', POPT_ARG_NONE, &help, 0},
	{ 0, 0, 0, 0, 0}
    };


    optCon = poptGetContext("implantisomd5", argc, (const char **)argv, options, 0);

    if ((rc = poptGetNextOpt(optCon)) < -1) {
        fprintf(stderr, "bad option %s: %s\n",
		poptBadOption(optCon, POPT_BADOPTION_NOALIAS),
		poptStrerror(rc));
        exit(1);
    }

    if (help)
	usage();

    args = poptGetArgs(optCon);
    if (!args || !args[0] || !args[0][0])
        usage();

    rc = implantISOFile((char *)args[0], supported, forceit, 0, &errstr);
    if (rc) {
	fprintf(stderr, "ERROR: %s\n", errstr);
	exit(1);
    } else {
	exit(0);
    }
}
