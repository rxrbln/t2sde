#!/bin/sh
#
# ROCK Linux is Copyright (C) 1998 - 2003 Clifford Wolf
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version. A copy of the GNU General Public
# License can be found at Documentation/COPYING.
#
# Revision: 1.1
# Author: Sebastian Jaenicke <sj-rocklinux@jaenicke.org>
#

NV_VERSION=4363

export IGNORE_CC_MISMATCH=1 

echo Installing GL libraries ..
cd NVIDIA_GLX-1.0-${NV_VERSION} && \
make install

echo Compiling kernel module ..
cd ../NVIDIA_kernel-1.0-${NV_VERSION} && \
make nvidia.o && \
install -m 0664 -o root -g root nvidia.o /lib/modules/`uname -r`/kernel/drivers/video/ && \
/sbin/depmod -a

if [ "x`grep nvidia /etc/devfsd.conf`" = "x" ]; then
	echo "Adding entries to /etc/devfsd.conf .."
	echo "LOOKUP nvidiactl        MODLOAD" >> /etc/devfsd.conf
	echo "LOOKUP nvidia0          MODLOAD" >> /etc/devfsd.conf
	echo "LOOKUP nvidia1          MODLOAD" >> /etc/devfsd.conf
fi

if [ "x`grep nvidia /etc/modules.conf`" = "x" ]; then
	echo "Adding entry to /etc/modules.conf .."
	echo "alias /dev/nvidia*   nvidia" >> /etc/modules.conf
fi

echo "Finished."
