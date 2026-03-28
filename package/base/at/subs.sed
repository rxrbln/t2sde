# --- T2-COPYRIGHT-BEGIN ---
# t2/package/*/at/subs.sed
# Copyright (C) 2004 - 2026 The T2 SDE Project
# Copyright (C) 1998 - 2003 ROCK Linux Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

s@_MAN_DIR@/usr/man@g
s@_GID_STRING@daemon@g
s@_ATSPOOL_DIR@/var/spool/atspool@g
s@_ATLIB_DIR@/usr/lib@g
s@_ATJOB_DIR@/var/spool/atjobs@g
s@_DEBUG@@g
s@_SYMB@-s@g
s@_DEFAULT_BATCH_QUEUE@E@g
s@_DEFAULT_AT_QUEUE@c@g
s@_PROC_DIR@/proc@g
s@_BIN_DIR@/usr/bin@g
s@_UID_STRING@daemon@g
s@_LOADAVG_MX@1.5@g
s@_PERM_PATH@/etc@g
s@_MAIL_CMD@/usr/sbin/sendmail@g
s@_DAEMON_GID@2@g
s@_DAEMON_UID@2@g
