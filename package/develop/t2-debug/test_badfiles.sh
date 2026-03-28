#!/bin/sh
#
# --- T2-COPYRIGHT-BEGIN ---
# t2/package/*/t2-debug/test_badfiles.sh
# Copyright (C) 2004 - 2026 The T2 SDE Project
# Copyright (C) 1998 - 2003 ROCK Linux Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---
#
# List known 'bad' files or directories found in the package db
#
# Output format:
# Package: File-Name
# ...

egrep -h ' opt/*/(etc|var)' /var/adm/flists/*
egrep -h ' (etc/ld.so.cache|usr/share/info/dir)$' /var/adm/flists/*

egrep -h '/perllocal.pod$' /var/adm/flists/* | grep -v '^perl:'

exit 0
