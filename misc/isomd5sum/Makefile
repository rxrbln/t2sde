
CFLAGS = -fPIC -D_FILE_OFFSET_BITS=64 -O -Wall -Werror
OBJECTS = md5.o implantisomd5.o libcheckisomd5.o implantisomd5.o checkisomd5.o
SOURCES = $(patsubst %.o,%.c,$(OBJECTS))
LDFLAGS = -lpopt

all: implantisomd5 checkisomd5

%.o: %.c
	gcc -c -O $(CFLAGS) -o $@ $<

implantisomd5: implantisomd5.o md5.o libimplantisomd5.o

checkisomd5: checkisomd5.o md5.o libcheckisomd5.o

clean:
	rm -f *.o *.lo *~
	rm -f implantisomd5 checkisomd5 

