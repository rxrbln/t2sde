#!/bin/sh
# --- T2-COPYRIGHT-BEGIN ---
# t2/package/*/rsbac/kernel.conf.sh
# Copyright (C) 2004 - 2026 The T2 SDE Project
# Copyright (C) 1998 - 2003 ROCK Linux Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

echo "Enabling RSBAC..."
echo -e '\nCONFIG_RSBAC=y\n' >> $1
