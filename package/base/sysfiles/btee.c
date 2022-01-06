/*  btee.c, a buffered tee clone   -   written for ROCK Linux

    Copyright (C) 1998, 1999, 2001, 2003  Clifford Wolf

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
*/

#define _GNU_SOURCE

#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <signal.h>
#include <stdlib.h>
#include <fcntl.h>

#define BUFFER_SIZE (8*1024-1)
static char buffer[BUFFER_SIZE+1];

#define EOT 004

void exit_handler(int sig) {
	exit(1);
}

int main(int argc, char ** argv) {
	int rc, mode, x, y;
	int remove_zeros=0;
	int pos=0, killme=0;
	
	if ( argc!=3 || (argv[1][0]!='a' && argv[1][0]!='t') ) {
		printf("Usage: %s {a|t} [file]\n",argv[0]);
		return 1;
	}
	
	if (argv[1][0]=='a')
		mode=O_WRONLY|O_CREAT|O_APPEND;
	else
		mode=O_WRONLY|O_CREAT|O_TRUNC;

	signal(SIGALRM, exit_handler);
	
	while (1) {
		if (killme == 1) {
			killme = -1;
			alarm(3);
		}

		if (pos >= BUFFER_SIZE) {
			fprintf(stderr, "%s: Buffer is full -> "
			        "drop data!\n",argv[0]);
			pos=0;
		}

		rc=read(0,buffer+pos,BUFFER_SIZE-pos);
		if (rc <= 0) return 0;
		buffer[pos+rc+1]=0;

		if (rc>0) {
			for (x=0; x<rc; x++) {
				if ( buffer[pos+x] != EOT )
					write(1,buffer+pos+x,1);
			}

			for (x=0; x<rc; x++) {
				if (buffer[pos+x]==EOT) {
					/* We wait a few seconds so we are
					 * still able to pipe thru 'early
					 * errors' from daemons. */
					buffer[pos+x]=0;
					if (!killme) killme = 1;
					remove_zeros=1;
				}
				if (buffer[pos+x]=='\r' &&
				    buffer[pos+x+1]!='\n') {
					for (y=pos+x; y>=0; y--) {
						if (buffer[y]=='\n') break;
						buffer[y]=0;
					}
					remove_zeros=1;
				}
			}

			pos+=rc;

			if (remove_zeros) {
				for (x=y=0; x<pos; x++) {
					if (buffer[x])
						buffer[y++]=buffer[x];
				}
				pos=y; remove_zeros=0;
			}

			rc=open(argv[2],mode,0666);
			if (rc>=0) {
				write(rc,buffer,pos);
				close(rc);
				pos=0;
				mode=O_WRONLY|O_APPEND;
			}
		}
	}
	
	return 0;
}
