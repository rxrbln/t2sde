#!/bin/bash
# --- T2-COPYRIGHT-BEGIN ---
# t2/package/*/vga2usb-firmware/extract-epiphan-fw.sh
# Copyright (C) 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

# Extract the Epiphan frame grabber firmware out of the vendor's vga2usb DKMS
# .deb and write it out as standalone files for request_firmware().
#
# The images are not shipped as files: they are linked into the binary-only
# object vga2usb_bins.o_shipped as compressed, relocation-addressed segment
# lists. extract-epiphan-fw.py walks those structures and rebuilds each image;
# this script only unpacks the .deb far enough to hand it that object.
#
# Usage: extract-epiphan-fw.sh <vga2usb-*.deb> [outdir]

set -e

deb="$1"
outdir="${2:-firmware/epiphan}"
here="$(cd "$(dirname "$0")" && pwd)"

[ -n "$deb" ] || { echo "usage: $0 <vga2usb-*.deb> [outdir]" >&2; exit 1; }
[ -r "$deb" ] || { echo "$0: $deb: cannot read" >&2; exit 1; }

for t in ar tar objdump python3; do
	command -v $t >/dev/null || { echo "$0: need $t" >&2; exit 1; }
done

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# A .deb is an ar archive holding data.tar.*; the payload name varies with the
# compressor the vendor's dpkg used, so match on the stem.
ar x "$(readlink -f "$deb")" --output "$tmp" 2>/dev/null || {
	( cd "$tmp" && ar x "$(readlink -f "$deb")" )
}

data="$(ls "$tmp"/data.tar.* 2>/dev/null | head -1)"
[ -n "$data" ] || { echo "$0: no data.tar.* inside $deb" >&2; exit 1; }

mkdir -p "$tmp/root"
tar -xf "$data" -C "$tmp/root"

obj="$(find "$tmp/root" -name 'vga2usb_bins.o_shipped' -print -quit)"
[ -n "$obj" ] || { echo "$0: vga2usb_bins.o_shipped not found in $deb" >&2; exit 1; }

echo "found $(basename "$obj") ($(stat -c %s "$obj") bytes)"
mkdir -p "$outdir"
python3 "$here/extract-epiphan-fw.py" -o "$outdir" "$obj"

n=$(find "$outdir" -type f | wc -l)
echo "extracted $n firmware images into $outdir"
[ "$n" -gt 0 ] || { echo "$0: nothing extracted" >&2; exit 1; }
