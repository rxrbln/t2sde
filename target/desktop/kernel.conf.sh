# here we disable all OSS modules - because they suck

echo "desktop target -> disabling oss sound modules ..."

sed -i -e "s/CONFIG_SOUND_OSS=./# CONFIG_SOUND_OSS is not set/" \
       -e"s/CONFIG_SOUND_PRIME=./# CONFIG_SOUND_PRIME is not set/" $1

# preemtion is not stable on PowerPC - so only enable it for x86 for now
if [ $arch = x86 ] ; then
	sed -i "s/# CONFIG_PREEMPT is not set/CONFIG_PREEMPT=y/" $1
else
	sed -i "s/CONFIG_PREEMPT=y/# CONFIG_PREEMPT is not set/" $1
fi

