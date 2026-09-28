#!/bin/bash
# --- T2-COPYRIGHT-BEGIN ---
# t2/package/*/flutter/system-dart.sh
# Copyright (C) 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

set -e
flutter_root=$(cd "$(dirname "$0")/../.." && pwd)
sdk="$flutter_root/bin/cache/dart-sdk"
if [ ! -x "$sdk/bin/dart" ] || [ ! -f "$sdk/lib/libraries.json" ] ||
   [ ! -f "$sdk/bin/snapshots/frontend_server_aot.dart.snapshot" ]; then
	echo "Flutter requires the complete system Dart SDK. Rebuild the T2 dart package." >&2
	exit 1
fi
cp "$flutter_root/bin/cache/engine.stamp" "$flutter_root/bin/cache/engine-dart-sdk.stamp"
