#!/usr/bin/perl -w
#
# This script checks the ROCK Linux dependency database
# against the proposed build order from the GNOME release
# notes and creates scripts/dep_fixes.txt entries based on
# the results.

use strict;

# this is fetched from
# http://www.gnome.org/start/2.6/notes/rninstallation.html
my @proposed_order = qw(
libxml2
libxslt
gtk-doc
glib
libidl
orbit2
intltool
libbonobo
fontconfig
Render
Xrender
Xft
pango
atk
shared-mime-info
gtk+
gconf
gnome-mime-data
gnome-vfs
esound
libgnome
libart_lgpl23
libglade
libgnomecanvas
libbonoboui
hicolor-icon-theme
gnome-icon-theme
gnome-keyring
libgnomeui
startup-notification
gtk-engines
gnome-themes
gnome-desktop
libwnck
scrollkeeper
gnome-panel
gnome-session
vte
gnome-terminal
libgtop
gail
gnome-applets
metacity
libgsf
libcroco
librsvg
eel
nautilus
control-center
gtkhtml
yelp
bug-buddy
libgnomeprint
libgnomeprintui
gtksourceview
gedit
eog
ggv
file-roller
gconf-editor
gnome-utils
gal
gnome-system-monitor
gstreamer
gst-plugins
gnome-media
nautilus-media
gnome-netstatus
gcalctool
gpdf
gucharmap
nautilus-cd-burner
zenity
gnome-speech
at-spi
gnome-mag
gnopernicus
gok
epiphany
gnomemeeting
gnome-games
gnome2-user-docs
);

my %deps;
my %bogus;

open(F, "<scripts/dep_db.txt") or die;
while (<F>) {
	my @list = split /[: \n]+/;
	my $p = shift @list;
	$deps{$p}{$_} = 1 foreach (@list);
}
close F;

while ($#proposed_order >= 0) {
	my $p = shift @proposed_order;

	foreach (@proposed_order) {
		$bogus{$p}{$_} = 1
			if defined $deps{$p}{$_};
	}
}

foreach my $p (sort keys %bogus) {
	print "$p\tdel\t", join(" ", sort keys %{$bogus{$p}}), "\n";
}

