#!/bin/sh
#
# --- T2-COPYRIGHT-BEGIN ---
# t2/package/*/t2-debug/test_unarchived.sh
# Copyright (C) 2004 - 2026 The T2 SDE Project
# Copyright (C) 1998 - 2003 ROCK Linux Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---
#
# List all files which are not listed in /var/adm/flists/*
#
# Output format:
# File-Name
# ...

{
  { find bin boot etc lib sbin usr var opt -type f -printf '~: %p\n'
    cat /var/adm/flists/* ; } | sort +1 |
  awk 'BEGIN { last=""; } $1=="~:" && last!=$2 { print $2; } { last=$2; }'

  ls | egrep -vx 'dev|home|lost\+found|mnt|proc|root|sys|tmp' |
  egrep -vx 'bin|boot|etc|lib|sbin|usr|var|opt'
} |
egrep -xv 'etc/ld.so.cache|usr/share/info/dir|lib/modules/.*/modules.dep'

exit 0
