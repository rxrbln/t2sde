#!/bin/sh
# --- T2-COPYRIGHT-BEGIN ---
# t2/architecture/microblaze/package/*/scripts_dvb.sh
# Copyright (C) 2004 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---
/bin/echo $1 | /bin/sed 's,dvb\([0-9]\)\.\([^0-9]*\)\([0-9]\),dvb/adapter\1/\2\3,'
