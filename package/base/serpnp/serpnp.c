
/*
 * Serial / COM PnP evaluation as defined in:
 *   "Plug and Play External COM Device  Specification"
 *     by Microsoft Corporation & Hayes Microcomputer Products, Inc.
 *     http://download.microsoft.com/download/1/6/1/161ba512-40e2-4cc9-843a-923143f3456c/pnpcom.rtf
 *
 * Copyright 2005 by René Rebe
 *
 * inspired partly by the X.org mouse/pnp code:
 *   Copyright 1998 by Kazutaka YOKOTA <yokota@zodiac.mech.utsunomiya-u.ac.jp>
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <unistd.h>

#include <termios.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#include <sys/ioctl.h>

struct symtab_t {
  char* name;
  char* drv;
};


/* PnP EISA/product IDs */
static symtab_t pnpsymtab[] = {
#ifdef notyet
    { "KML0001",  PROT_THINKING },	/* Kensignton ThinkingMouse */
#endif
    { "MSH0001",  "-ms3" },	/* MS IntelliMouse */
    { "MSH0004",  "-ms3" },	/* MS IntelliMouse TrackBall */
    { "KYEEZ00",  "-ms" },		/* Genius EZScroll */
    { "KYE0001",  "-ms" },		/* Genius PnP Mouse */
    { "KYE0002",  "-ms" },		/* MouseSystem (Genius?) SmartScroll */
    { "KYE0003",  "-ms3" },	/* Genius NetMouse */
    { "LGI800)",  "-ms" },	/* Logitech FirstMouse+ */ // HACK -ReneR
    { "LGI800C",  "-ms3" },	/* Logitech MouseMan (4 button model) */
    { "LGI8033",  "-ms3" },	/* Logitech Cordless MouseMan Wheel */
    { "LGI8050",  "-ms3" },	/* Logitech MouseMan+ */
    { "LGI8051",  "-ms3" },	/* Logitech FirstMouse+ */
    { "LGI8001",  "-ms" },	/* Logitech serial */ // was -mman -ReneR
    { "A4W0005",  "-ms3" },	/* A4 Tech 4D/4D+ Mouse */
    { "PEC9802",  "-ms3" },	/* 8D Scroll Mouse */

#ifdef notyet
    { "PNP0F00",  PROT_BM },		/* MS bus */
#endif
    { "PNP0F01",  "-ms" },		/* MS serial */
#ifdef notyet
    { "PNP0F02",  PROT_BM },		/* MS InPort */
#endif
    /*
     * EzScroll returns PNP0F04 in the compatible device field; but it
     * doesn't look compatible... XXX
     */
    { "PNP0F04",  "-msc" },		/* MouseSystems */ 
    { "PNP0F05",  "-msc" },		/* MouseSystems */ 
#ifdef notyet
    { "PNP0F06",  PROT_??? },		/* Genius Mouse */ 
    { "PNP0F07",  PROT_??? },		/* Genius Mouse */ 
#endif
    { "PNP0F08",  "-mman" },	/* Logitech serial */
    { "PNP0F09",  "-ms" },		/* MS BallPoint serial */
    { "PNP0F0A",  "-ms" },		/* MS PnP serial */
    { "PNP0F0B",  "-ms" },		/* MS PnP BallPoint serial */
    { "PNP0F0C",  "-ms" },		/* MS serial comatible */
#ifdef notyet
    { "PNP0F0D",  PROT_BM },		/* MS InPort comatible */
#endif
    { "PNP0F0F",  "-ms" },		/* MS BallPoint comatible */
#ifdef notyet
    { "PNP0F10",  PROT_??? },		/* TI QuickPort */
    { "PNP0F11",  PROT_BM },		/* MS bus comatible */
    { "PNP0F14",  PROT_??? },		/* MS Kids Mouse */
    { "PNP0F15",  PROT_BM },		/* Logitech bus */ 
    { "PNP0F16",  PROT_??? },		/* Logitech SWIFT */
#endif
    { "PNP0F17",  "-mman" },	/* Logitech serial compat */
#ifdef notyet
    { "PNP0F18",  PROT_BM },		/* Logitech bus compatible */
    { "PNP0F1A",  PROT_??? },		/* Logitech SWIFT compatible */
    { "PNP0F1B",  PROT_??? },		/* HP Omnibook */
    { "PNP0F1C",  PROT_??? },		/* Compaq LTE TrackBall PS/2 */
    { "PNP0F1D",  PROT_??? },		/* Compaq LTE TrackBall serial */
    { "PNP0F1E",  PROT_??? },		/* MS Kids Trackball */
#endif
    { NULL,	  NULL },
};

/* serial PnP ID string */
struct pnpid_t {
  int   revision;    /* PnP revision, 100 for 1.00 */
  char* eisaid;	     /* EISA ID including mfr ID and product ID */
  char* serial;      /* serial No, optional */
  char* devclass;       /* device class, optional */
  char* compat;      /* list of compatible drivers, optional */
  char* description; /* product description, optional */
  int   neisaid;     /* length of the above fields... */
  int   nserial;
  int   ndevclass;
  int   ncompat;
  int   ndescription;
};

bool pnpparse (pnpid_t* id, char* buf, int len)
{
    char s[3];
    int offset;
    int sum = 0;
    int i, j;

    id->revision = 0;
    id->eisaid = NULL;
    id->serial = NULL;
    id->devclass = NULL;
    id->compat = NULL;
    id->description = NULL;
    id->neisaid = 0;
    id->nserial = 0;
    id->ndevclass = 0;
    id->ncompat = 0;
    id->ndescription = 0;

    offset = 0x28 - buf[0];

    /* calculate checksum */
    for (i = 0; i < len - 3; ++i) {
	sum += buf[i];
	buf[i] += offset;
    }
    sum += buf[len - 1];
    for (; i < len; ++i)
	buf[i] += offset;
    //printf ("PnP ID string: `%*.*s'\n", len, len, buf);

    /* revision */
    buf[1] -= offset;
    buf[2] -= offset;
    id->revision = ((buf[1] & 0x3f) << 6) | (buf[2] & 0x3f);
    //printf ("PnP rev %d.%02d\n", id->revision / 100, id->revision % 100);

    /* EISA vender and product ID */
    id->eisaid = &buf[3];
    id->neisaid = 7;
    
    // workaround for my Logitech mice? only has 6 ... -ReneR
    // if (id->eisaid [id->neisaid-1] == ')')
    //  id->neisaid--;
    
    //printf ("PnP EISA ID: %s\n", id->eisaid);
    
    /* option strings */
    i = 10;
    if (buf[i] == '\\') {
        /* device serial # */
        for (j = ++i; i < len; ++i) {
            if (buf[i] == '\\')
		break;
        }
	if (i >= len)
	    i -= 3;
	if (i - j == 8) {
            id->serial = &buf[j];
            id->nserial = 8;
	}
    }
    if (buf[i] == '\\') {
        /* PnP class */
        for (j = ++i; i < len; ++i) {
            if (buf[i] == '\\')
		break;
        }
	if (i >= len)
	    i -= 3;
	if (i > j + 1) {
            id->devclass = &buf[j];
            id->ndevclass = i - j;
        }
    }
    if (buf[i] == '\\') {
	/* compatible driver */
        for (j = ++i; i < len; ++i) {
            if (buf[i] == '\\')
		break;
        }
	/*
	 * PnP COM spec prior to v0.96 allowed '*' in this field, 
	 * it's not allowed now; just ignore it.
	 */
	if (buf[j] == '*')
	    ++j;
	if (i >= len)
	    i -= 3;
	if (i > j + 1) {
            id->compat = &buf[j];
            id->ncompat = i - j;
        }
    }
    if (buf[i] == '\\') {
	/* product description */
        for (j = ++i; i < len; ++i) {
            if (buf[i] == ';')
		break;
        }
	if (i >= len)
	    i -= 3;
	if (i > j + 1) {
            id->description = &buf[j];
            id->ndescription = i - j;
        }
    }

    /* checksum exists if there are any optional fields */
    if ((id->nserial > 0) || (id->ndevclass > 0)
	|| (id->ncompat > 0) || (id->ndescription > 0)) {
      printf ("PnP checksum: 0x%02X\n", sum);
      sprintf(s, "%02X", sum & 0x0ff);
        if (strncmp(s, &buf[len - 3], 2) != 0) {
	  printf ("checksum error!");
#if 0
            /* 
	     * Checksum error!!
	     * I found some mice do not comply with the PnP COM device 
	     * spec regarding checksum... XXX
	     */
	    return false;
#endif
        }
    }

    return true;
}

int tty = 0;
struct termios oldserial_io;

void tty_cleanup()
{
  printf ("Resetting port ...\n");
  tcsetattr(tty, TCSANOW, &oldserial_io);
}

int main (int argc, char* argv[])
{
  struct termios newserial_io;

  if (argc <= 1) {
    printf("Usage: %s devname\n", argv[0]);
    return -1;
  }

  //open Serialport for reading and writing
  tty = open (argv[1], O_RDWR | O_NOCTTY);
  
  if (tty < 0) {
    perror("serial port");
    return 0;
  }
  
  // save current serial port settings
  tcgetattr(tty, &oldserial_io);
  tcgetattr(tty, &newserial_io);
  
  // control
  //   raw mode
  newserial_io.c_lflag &= ~(ICANON | ECHO | ECHOE | ISIG);
  newserial_io.c_cc[VTIME] = 2;
  newserial_io.c_cc[VMIN] = 0;
  
  cfsetispeed(&newserial_io, B1200);
  newserial_io.c_cflag &= ~CSIZE;
  newserial_io.c_cflag |= CS7;

  atexit (tty_cleanup);
  
  tcflush(tty, TCIFLUSH);
  
  tcsetattr(tty,TCSANOW,&newserial_io);
  
  // This is a simplified procedure; it simply toggles RTS.

  unsigned int i;
  ioctl(tty, TIOCMGET, &i);
  i |= TIOCM_DTR; // DTR = 1
  i &= ~TIOCM_RTS; // RTS = 0
  ioctl(tty, TIOCMSET, &i);

  usleep(200000);

  /* wait for respose */
  tcflush(tty, TCIFLUSH);
  i |= TIOCM_DTR | TIOCM_RTS; // DTR = 1, RTS = 1
  ioctl(tty, TIOCMSET, &i);

  bool non_pnp_mice = false;
  bool pnp = true;
  unsigned char c;

  char buf [256];
  i = 0;

  while (read (tty, &c, 1) == 1) {
	  if (c == 'M')
		  non_pnp_mice = true;


	  if ((c == 0x08) || (c == 0x28)) {	/* Begin ID */
		  buf[0] = c;
		  i = 1;
		  break;
	  }
  }

  if (i <= 0) {
	  /* we haven't seen `Begin ID' in time... */
	  return 0;
  }

  ++c; /* make it `End ID' */
  while (read (tty, &buf[i], 1) == 1) {
	  if (buf[i++] == c)	/* End ID */
		  break;
	  if (i >= sizeof(buf))
      return 1;
  }
  
  printf ("God PnP fields - %d bytes:\n", i);
  
  for (unsigned int j = 0; j < i; ++j)
    printf ("%d %x\n", buf[j], buf[j]);
  
  pnpid_t id;
  pnpparse (&id, buf, i);
  
  printf ("%.*s\n", id.neisaid, id.eisaid);
  
  if (id.ndevclass > 0) {
    printf ("CLASS: %.*s\n", id.ndevclass, id.devclass);
  }
  else {
    symtab_t* it = pnpsymtab;
    while (it->name != 0 && strncmp(it->name, id.eisaid, id.neisaid) != 0)
      ++it;
    if (it->name != 0)
      printf ("CLASS: MOUSE %s\n", it->drv);
  }
  
  return 0;
}
