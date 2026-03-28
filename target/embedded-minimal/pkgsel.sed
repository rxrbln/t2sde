# --- T2-COPYRIGHT-BEGIN ---
# t2/target/embedded-minimal/pkgsel.sed
# Copyright (C) 2008 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

# Only build the toolchain packages in the toolchain stage (0)
# (with stage 1, as canadian cross they would end up in the
#  target system!).

/ binutils /		{ s,^. [^ ]*,X 0---------,; p; d; }
/ gcc /			{ s,^. [^ ]*,X 0---------,; p; d; }
/ gmp /			{ s,^. [^ ]*,X 0---------,; p; d; }
/ mpfr /		{ s,^. [^ ]*,X 0---------,; p; d; }
