#!/usr/bin/perl -w

use strict;
use English;

my $min_points = 50;

my %tuples;

while (<>) {
	next unless /^\*\*\s+([0-9\.]+):\s+(\S+)\s+(\S+)/;
	$tuples{sprintf "%-14s\t%-22s", $2, $3} += $1;
}

foreach (keys %tuples) {
	next if $tuples{$_} < 50;
	printf "** %9.0f:\t%s\n", $tuples{$_}, $_;
}

