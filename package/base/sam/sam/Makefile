CC = gcc
CFLAGS = -g -O2 -fpic -fPIC

LD = ld
LDFLAGS = -shared -E

all: tokenize.so

tokenize.so: tokenize.o
	$(LD) $(LDFLAGS) -o $@ $<

