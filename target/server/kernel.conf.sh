# here we disable all OSS modules - because they suck

echo "desktop target -> disabling sound modules ..."

sed "s/CONFIG_SOUND_\(.*\)=./# CONFIG_SOUND_\1 is not set/" $1 > .config.desktop
mv .config.desktop $1

