#!/bin/sh
#
# --- T2-COPYRIGHT-BEGIN ---
# t2/package/*/ifhp/dummy_gs.sh
# Copyright (C) 2004 - 2026 The T2 SDE Project
# Copyright (C) 1998 - 2003 ROCK Linux Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

for x ; do
	if [ "${x%=*}" = "-sOutputFile" ]; then
		if [ "${x#*=}" = "-" ]; then echo "XXX"
		else echo "XXX" > "${x#*=}"; fi
	fi
done
