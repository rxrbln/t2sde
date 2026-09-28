#!/bin/bash
# --- T2-COPYRIGHT-BEGIN ---
# t2/package/*/flutter/flutter.sh
# Copyright (C) 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

set -e
source_root='@DATADIR@/flutter'
if [ ! -x "$source_root/bin/cache/dart-sdk/bin/dart" ]; then
	echo "Flutter requires the system Dart SDK. Rebuild the T2 dart package." >&2
	exit 1
fi
cache_root="${XDG_CACHE_HOME:-$HOME/.cache}/flutter-t2"
flutter_root="$cache_root/@VERSION@-@REVISION@"
mkdir -p "$cache_root"

(
	flock 9
	if [ ! -d "$flutter_root" ]; then
		work=$(mktemp -d "$cache_root/.setup.XXXXXXXX")
		trap 'rm -rf -- "$work"' EXIT
		cp -a "$source_root/." "$work/"
		chmod -R u+w "$work"
		git -C "$work" init -q -b stable
		git -C "$work" add .
		git -C "$work" add -f bin/internal/engine.version
		git -C "$work" -c user.name='T2 SDE' -c user.email='t2@t2-project.org' \
			-c commit.gpgsign=false -c core.hooksPath=/dev/null \
			commit -qm 'Flutter @VERSION@ with T2 system Dart integration'
		git -C "$work" -c tag.gpgsign=false tag '@VERSION@'
		mv "$work" "$flutter_root"
		trap - EXIT
	fi
) 9> "$cache_root/.setup.lock"

exec "$flutter_root/bin/flutter" "$@"
