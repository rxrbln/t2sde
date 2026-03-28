# --- T2-COPYRIGHT-BEGIN ---
# t2/misc/confdialog/Makefile
# Copyright (C) 2004 - 2026 The T2 SDE Project
# Copyright (C) 1998 - 2003 ROCK Linux Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

OBJS = checklist.o menubox.o textbox.o yesno.o inputbox.o \
       util.o confdialog.o msgbox.o

%.o: %.c
	gcc -c -o $@ $<

confdialog: $(OBJS)
	gcc -o confdialog $(OBJS) -lncurses

clean:
	rm -f core *.o *~ confdialog

