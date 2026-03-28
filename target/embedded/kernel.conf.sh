# --- T2-COPYRIGHT-BEGIN ---
# t2/target/embedded/kernel.conf.sh
# Copyright (C) 2004 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---
# here we disable all OSS modules - because they suck

echo "desktop target -> disabling oss sound modules ..."

sed -i -e "s/CONFIG_VIDEO_DEV=./# CONFIG_VIDEO_DEV is not set/" \
       -e "s/CONFIG_DVB=./# CONFIG_DVB is not set/" \
       -e "s/CONFIG_FB=./# CONFIG_FB is not set/" \
       -e "s/CONFIG_SOUND=./# CONFIG_SOUND is not set/" \
       -e "s/CONFIG_PHONE=./# CONFIG_PHONE is not set/" \
       -e "s/CONFIG_I2O=./# CONFIG I2O is not set/" \
       -e "s/CONFIG_AGP=./# CONFIG AGP is not set/" \
       -e "s/CONFIG_DRM=./# CONFIG DRM is not set/" \
       -e "s/CONFIG_\(.*\)GAMEPORT=./# CONFIG_\1GAMEPORT is not set/" $1

