#!/bin/bash
# --- T2-COPYRIGHT-BEGIN ---
# t2/misc/luabash/example/example.sh
# Copyright (C) 2006 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

#
# This is a simple lua bash example.

# init lua bash and load code chunk from file internal.lua.
enable -f ../luabash.so luabash
luabash load ./internal.lua

# perform some arithmetic using a lua function called "plus".
total=0
for ((i=1;i<3;i++)) ; do
   for ((j=1;j<3;j++)) ; do
	plus $i $j
   done
done
echo "total sum is: " $total


# bash function to be called from within lua context
some_bashy_function ()
{
    if [ -n "$2" ] ; then
	shift
	some_bashy_function $@
	echo "$1"
    fi
}

# call the lua function that calls bash function above
callbash

# test if io redirection works
cat <<EOF | redirections | sed 's,xx,yy,g'
line one
line two
line three
EOF

# print ten shell variables
printenv | head -n 10

one
echo $?

zero
echo $?

str
echo $?

boolean
echo $?
