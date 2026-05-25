# --- T2-COPYRIGHT-BEGIN ---
# t2/package/*/perl/perllocal_hack.sh
# Copyright (C) 2004 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

if atstage native; then

# Quick & Dirty hack for the perllocal problem
# .. to be included by packages which do 'share' the perllocal.pod file
#
eval `perl -V:archlib`
hook_add premake 1 "( cd $archlib; mv -v perllocal.pod perllocal.pod.sik || true; )"
hook_add postmake 9 "( cd $archlib; mv -v perllocal.pod $pkg.pod || true;
		       mv -v perllocal.pod.sik perllocal.pod || true; )"
var_append flist''del '|' "${archlib#/}/perllocal.pod"

fi
