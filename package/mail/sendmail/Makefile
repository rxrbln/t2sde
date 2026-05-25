# --- T2-COPYRIGHT-BEGIN ---
# t2/package/*/sendmail/Makefile
# Copyright (C) 2004 - 2026 The T2 SDE Project
# Copyright (C) 1998 - 2003 ROCK Linux Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

all: sendmail.cf aliases.db

aliases.db: aliases sendmail.cf
	newaliases

sendmail.cf: sendmail.mc
	m4 m4/cf.m4 sendmail.mc > sendmail.cf

clean:
	rm -f *~ sendmail.cf aliases.db
