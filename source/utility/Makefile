include build/top.make

NOT_INCS := BinomiHeap.hh
NOT_SRCS += Lua.cc

BINARY = libgsmutil
BINARY_EXT = $(X_DYNEXT)
DEPS =

CXXFLAGS += -I utility/
LDFLAGS += $(SIGC2LIBS) # -ldl -pthread 

include build/bottom.make
