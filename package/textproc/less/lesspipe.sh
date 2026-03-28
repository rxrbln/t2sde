#!/bin/sh
#
# --- T2-COPYRIGHT-BEGIN ---
# t2/package/*/less/lesspipe.sh
# Copyright (C) 2004 - 2026 The T2 SDE Project
# Copyright (C) 1998 - 2003 ROCK Linux Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

case "$1" in
	# Archives
	*.a) ar t $1;;
	*.tar) tar tvf $1;;
	*.tgz|*.tar.gz|*.tar.[Zz]) tar tvfz $1;;
	*.tbz2|*.tar.bz2) tar tvfI $1;;
	*.zip) unzip -l $1;;
	# Packages
	*.gem) mine -p $1 ; echo -e "\nFile List:" ; mine -l $1;;
	*.rpm) rpm -q -i -p $1 ; echo "File List   :" ; rpm -q -l -p $1;;
	# Manuals
	*ld.so.8) nroff -p -t -c -mandoc $1;;
	*.so.*) ;;
	*.[1-9]|*.[1-9][mxt]|*.[1-9]thr|*.man)
		nroff -p -t -c -mandoc $1;;
	# Compressed manuals
	*.[1-9].gz|*.[1-9][mxt].gz|*.[1-9]thr.gz|*.man.gz|\
	*.[1-9].[Zz]|*.[1-9][mxt].[Zz]|*.[1-9]thr.[Zz]|*.man.[Zz])
		gzip -c -d $1 | nroff -p -t -c -mandoc;;
	*.[1-9].bz2|*.[1-9][mxt].bz2|*.[1-9]thr.bz2|*.man.bz2)
		bzip2 -c -d $1 | nroff -p -t -c -mandoc ;;
	# Compressed files
	*.gz|*.Z|*.z) gzip -c -d $1;;
	*.bz2) bzip2 -c -d $1;;
esac
