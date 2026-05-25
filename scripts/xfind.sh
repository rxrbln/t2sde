#!/usr/bin/env bash
# --- T2-COPYRIGHT-BEGIN ---
# t2/scripts/xfind.sh
# Copyright (C) 2004 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

# Subversion has really big ".svn" subdirs. This has much better performance
# than the "find ... ! -path '*/.svn*' ! -path '*/CVS*' ..." used earlier
# in various places. Never use this with -depth! Instead pipe the output thru
# "tac" or "sort -r".

dirs=""; while [ -n "${1##[-\(\!]*}" ]; do dirs="$dirs $1"; shift; done
if [ $# -eq 0 ]; then set -- -print; fi;
action=") -print"; if [ "${*#-print}" != "$*" ]; then action=""; fi
find $dirs '(' -path '*/.svn' -o -path '*/CVS' -o -path .git ')' -prune -o ${action:+\(} "$@" $action
