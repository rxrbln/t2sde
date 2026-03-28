# --- T2-COPYRIGHT-BEGIN ---
# t2/package/*/sysfiles/issue-std.sh
# Copyright (C) 2021 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

cat > etc/issue << EOT
___________       _________
__  /__|__ \\\\____________  /____
_  __/___/ /_  ___/  __  /_  _ \\\\
/ /_ _  __/_(__  )/ /_/ / /  __/
\\\\__/ /____//____/ \\\\__,_/  \\\\___/

\\t \\d  --  \\U online  --  line [\\l].

Welcome to \\n ($sdetxt, Kernel \\r).

EOT
