#!/bin/sh
#
# --- T2-COPYRIGHT-BEGIN ---
# t2/package/*/t2-debug/test_empty.sh
# Copyright (C) 2004 - 2026 The T2 SDE Project
# Copyright (C) 1998 - 2003 ROCK Linux Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---
#
# List all empty files stored in the package database and list
# all empty packages.
#
# Output format:
# File-Name
# ...

cd /; find var/adm/md5sums -type f -empty
grep -h ' 0 ' var/adm/md5sums/* | cut -f3 -d' '

exit 0
