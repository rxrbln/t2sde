# here we disable all OSS modules - because they suck

echo "desktop target -> disabling oss sound modules ..."

sed "s/CONFIG_SOUND_OSS=./# CONFIG_SOUND_OSS is not set/" $1 > .config.desktop
mv .config.desktop $1

