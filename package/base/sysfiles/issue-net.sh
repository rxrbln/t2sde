# --- T2-COPYRIGHT-BEGIN ---
# t2/package/*/sysfiles/issue-net.sh
# Copyright (C) 2021 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

cat > etc/issue.net << EOT
  __  ___         __
 / /_|_  |___ ___/ /__ 
/ __/ __/(_-</ _  / -_)
\\\\__/____/___/\\\\_,_/\\\\__/

%d  --  line [%t].

Welcome to %h ($sdetxt).

EOT
