
#ifndef MD5_H
#define MD5_H

#include <sys/types.h>

#ifdef __dietlibc__
typedef uint32_t uint32;
#else
typedef u_int32_t uint32;
#endif

struct MD5Context {
	uint32 buf[4];
	uint32 bits[2];
	unsigned char in[64];
	int doByteReverse;
};

void MD5_Init(struct MD5Context *);
void MD5_Update(struct MD5Context *, unsigned const char *, unsigned);
void MD5_Final(unsigned char digest[16], struct MD5Context *);

/*
 * This is needed to make RSAREF happy on some MS-DOS compilers.
 */

typedef struct MD5Context MD5_CTX;

#endif				/* MD5_H */
