#!/bin/sh
for x in * ; do [ -L $x -o -f $x/AUTOCREATED ] && rm -rf $x ; done
