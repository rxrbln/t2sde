#!/bin/sh
#
# --- T2-COPYRIGHT-BEGIN ---
# t2/package/*/t2-debug/test_shares.sh
# Copyright (C) 2004 - 2026 The T2 SDE Project
# Copyright (C) 1998 - 2003 ROCK Linux Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---
#
# List all filenames which are assigned to multiple packages in the
# package database files /var/adm/flists/*
#
# Output format:
# Package1 <Tab> Package2 <Tab> Filename
# ...

sort +1 /var/adm/flists/* | sed 's, ,|,' | \
awk 'BEGIN { FS="|"; last=""; lastpkg=""; } $2==last { print lastpkg, $1, $2; }
{ lastpkg=$1; last=$2; }' | sed 's,: ,	,g'

exit 0
