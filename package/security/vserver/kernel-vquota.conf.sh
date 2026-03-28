#!/bin/bash
# --- T2-COPYRIGHT-BEGIN ---
# t2/package/*/vserver/kernel-vquota.conf.sh
# Copyright (C) 2004 - 2026 The T2 SDE Project
# Copyright (C) 1998 - 2003 ROCK Linux Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

echo "CONFIG_QUOTA=y" >> $1
echo "CONFIG_BLK_DEV_VROOT=y" >> $1
