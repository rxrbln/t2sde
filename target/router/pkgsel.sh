#!/bin/sh
#
# We only need iptables, ip+tc, ssh and a kernel. But since we would
# make a native build we need a lot of other stuff for building those
# packages. This is autodetected here.
#
# Various small other packages (like bash and fileutils) which are
# also needed for the router are selected automatically because of the
# dependencies ...

perl -e '
	my @x=qw/iptables iproute2 openssh linux24 util-linux time
	         coreutils procps strace pciutils 00-dirtree/;
	$b{$_}=1 foreach @x;
	print "\n";
	print "ALL: ".join(" ", @x)."\n";
	print "\n";
	while (<>) {
		next unless /(.*): [0-9]* [0-9]* (.*)/;
		my ($pkg, $deps) = ($1, '');
		foreach (split /\s+/, $2) {
			next if /^(linux26|alsa|rpm|pam|gcc2)([^a-z]|$)/;
			next unless -d "../../package/base/$_";
			$deps .= " $_"; $b{$_} = 1;
		}
		print "$pkg: $deps\n\t\@echo \"\/ $pkg \/ { p; d; }\"\n";
		$a{$pkg} = 1;
	}
	foreach (keys %b) { print "$_:\n\t\@echo \"/ $_ / { p; d; }\"\n\n" if not defined $a{$_}; }
' < ../../scripts/dep_db.txt > pkgsel.mk

echo '# This file is auto-generated from pkgsel.sh' > pkgsel.sed
make -f pkgsel.mk ALL 2> /dev/null | sort -u >> pkgsel.sed
echo 'd;' >> pkgsel.sed; rm -f pkgsel.mk

