#!/bin/sh
#
# --- T2-COPYRIGHT-BEGIN ---
# t2/package/*/t2-debug/test_bindups.sh
# Copyright (C) 2004 - 2026 The T2 SDE Project
# Copyright (C) 1998 - 2003 ROCK Linux Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---
#
# List all binary names which are used more than once in various bin dirs.
#
# Output format:
# Bin-Name <Tab> Dir1 <Tab> Dir2
# ...

find {,/usr,/usr/local}/{,s}bin -type f -printf '%f %H\n' |
sort | awk 'BEGIN { OFS="\t"; last=""; lastdir=""; }
$1==last { print $1, lastdir, $2; } { lastdir=$2; last=$1; }'

exit 0
