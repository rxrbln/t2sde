topdir  = .
subdirs = cf lua

all:

include $(topdir)/cf/Rules.pre

LIBRARIES = luabash.so
INCLUDES = -Ilua/
LIBS = lua/liblua.al -lm -ldl

luabash_so_SRCS = luabash.c

include $(topdir)/cf/Rules

$(luabash_so_OBJS): Config lua/luaconf.h
luabash.so: $(luabash_so_OBJS)
	$(call link-library)

include $(topdir)/cf/Rules.post

help:
	@echo "Usage: make [Options] [Targets]"; \
	echo  ; \
	echo "Options:" ; \
	echo "   VERBOSE=1         Make all compile steps visible (default: $(VERBOSE))." ; \
	echo "   DEBUG=1           Compile with debugging support (default: $(DEBUG))" ; \
	echo "   PROFILE=1         Compile with profiling support (default: $(PROFILE))" ; \
	echo ; \
	echo "Targets:" ; \
	echo "   help              This." ; \
	echo "   all               Compile (default)." ; \
	echo "   clean             Clean up (remove compiled sources)." ; \
	echo
