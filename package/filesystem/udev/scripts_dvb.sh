#!/bin/sh
/bin/echo $1 | /bin/sed 's,dvb\([0-9]\)\.\([^0-9]*\)\([0-9]\),dvb/adapter\1/\2\3,'

