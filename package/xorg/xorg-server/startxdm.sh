#!/bin/sh
# --- T2-COPYRIGHT-BEGIN ---
# t2/package/*/xorg-server/startxdm.sh
# Copyright (C) 2004 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

XDM="/usr/X11/bin/xdm -nodaemon"

[ -e /etc/conf/xdm ] && . /etc/conf/xdm

exec $XDM
