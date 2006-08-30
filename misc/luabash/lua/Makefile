topdir  = ..
subdirs = 

all:

include $(topdir)/cf/Rules.pre

LARCHIVES = liblua.al
liblua_al_SRCS = $(wildcard *.c)

CLEAN_FILES += luaconf.h

include $(topdir)/cf/Rules

$(liblua_al_OBJS): luaconf.h
liblua.al: $(liblua_al_OBJS)
	$(call link-archive)

include $(topdir)/cf/Rules.post
