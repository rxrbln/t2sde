#!/bin/bash
# --- T2-COPYRIGHT-BEGIN ---
# t2/misc/archive/GenDepGraph.sh
# Copyright (C) 2004 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

if [ -z "$1" ] ; then
    cat  1>&2 <<-EOT
graphviz dependency graph generator
usage:
    $0 <list of package dirs>

output can be compiled with graphviz, for example:
# $0 package/kde/* > kde-deps.dot
# dot -Tps kde-deps.dot > kde-deps.ps
EOT
    exit 1
fi

pattern=`mktemp`
result=`mktemp`
dscs="";
for p in $@ ; do
    desc=`ls $p/*.cache 2> /dev/null | head -n 1`
    if [ -r "$desc" ] ; then
	dscs="$dscs "$desc
	echo '\[DEP\] '`basename $p` >> $pattern
    else
	echo "warning: no cache file for $p" 1>&2
    fi
done

grep -f $pattern $dscs > $result

echo "Digraph G {"
sed 's,.*/\([^.]*\).*\[DEP\] \(.*\),\"\1\" -> \"\2\",g' $result
echo "}"

rm $pattern
rm $result
