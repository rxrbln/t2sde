#!/bin/sh
#
# --- T2-COPYRIGHT-BEGIN ---
# t2/package/*/cron/cron.run.sh
# Copyright (C) 2004 - 2026 The T2 SDE Project
# Copyright (C) 1998 - 2003 ROCK Linux Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

if [ "$1" = "-mail-to-root" ]; then
	$0 2>&1 | mail -s "Cron at `hostname` [`date +%Y-%m-%d`]" root
	exit
fi

x="$( hostname -f 2> /dev/null )"
echo "Output of the daily cron at ${x:-localhost}."
echo "Local time is `date | tr -s ' '`."
echo

cd /

for x in /etc/cron.daily/*
do
	echo "-- $x"
	echo
	$x
done
