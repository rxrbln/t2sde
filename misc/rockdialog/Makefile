
OBJS = checklist.o menubox.o textbox.o yesno.o inputbox.o \
       util.o rockdialog.o msgbox.o

%.o: %.c
	gcc -c -o $@ $<

rockdialog: $(OBJS)
	gcc -o rockdialog $(OBJS) -lncurses

clean:
	rm -f core *.o *~ rockdialog

