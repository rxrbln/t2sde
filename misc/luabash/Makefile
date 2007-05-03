
# special T2 related output location
X_OUTTOP=../../src
libdir=$(X_OUTTOP)

CFLAGS = -Wall -O2 -s -fPIC
#CFLAGS = -Wall -O0 -ggdb -fPIC

# ExactBuild does use CXX to link a .so right now
# (this should probably be done in a saner way)
CXX = $(CC)

MODULES = lua bash
include $(addsuffix /Makefile,$(MODULES))
