CC = gcc
LD = gcc
RM = rm -f
CFLAGS = -c -Wall -O2 -fomit-frame-pointer
LDFLAGS = -s

PCAP_H = -I/usr/include/pcap
PCAP_L = -lpcap

NIDS_H = -I/usr/local/include
NIDS_L = -L/usr/local/lib -lnids -lnet -lpcap

PROJ = scanlogd

OBJS_COMMON = scanlogd.o
OBJS = $(OBJS_COMMON) in_linux.o in_nids.o in_pcap.o

default: libnids

install: default
	cp -f scanlogd $(ROOT)/$(PREFIX)/sbin/

linux: $(OBJS_COMMON) in_linux.o
	$(LD) $(LDFLAGS) $(OBJS_COMMON) in_linux.o -o scanlogd

libnids: $(OBJS_COMMON) in_nids.o
	$(LD) $(LDFLAGS) $(OBJS_COMMON) in_nids.o $(NIDS_L) -o scanlogd

libpcap: $(OBJS_COMMON) in_pcap.o
	$(LD) $(LDFLAGS) $(OBJS_COMMON) in_pcap.o $(PCAP_L) -o scanlogd

in_pcap.o: params.h in.h
	$(CC) $(CFLAGS) $(PCAP_H) in_pcap.c

in_nids.o: params.h in.h
	$(CC) $(CFLAGS) $(NIDS_H) in_nids.c

scanlogd.o: params.h in.h
in_linux.o: params.h in.h

.c.o:
	$(CC) $(CFLAGS) $*.c

clean:
	$(RM) $(PROJ) $(OBJS)
