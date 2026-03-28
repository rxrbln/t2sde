#!/bin/sh
#
# --- T2-COPYRIGHT-BEGIN ---
# t2/package/*/t2-debug/test_baduidgid.sh
# Copyright (C) 2004 - 2026 The T2 SDE Project
# Copyright (C) 1998 - 2003 ROCK Linux Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---
#
# List all files with unknown UID or GID
#
# Output format:
# File-Name <Tab> UID:GID
# ...

find * \( -nouser -o -nogroup \) -printf '%p\t%u:%g\n'

exit 0
