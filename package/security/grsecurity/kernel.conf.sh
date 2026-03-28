#!/bin/sh
# --- T2-COPYRIGHT-BEGIN ---
# t2/package/*/grsecurity/kernel.conf.sh
# Copyright (C) 2004 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

echo "Enabling grsecurity..."
echo "CONFIG_GRKERNSEC=y" >> $1
