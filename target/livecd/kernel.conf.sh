# here we disable settings we'll most probably not need on the bootdisk

echo "bootdisk target -> disabling some settings ..."

sed -e "s/CONFIG_SOUND_\(.*\)=./# CONFIG_SOUND_\1 is not set/" \
    -e "s/CONFIG_VIDEO\(.*\)=./# CONFIG_VIDEO\1 is not set/" \
    -e "s/CONFIG_PHONE\(.*\)=./# CONFIG_PHONE\1 is not set/" \
    -e "s/CONFIG_RADIO\(.*\)=./# CONFIG_RADIO\1 is not set/" \
    -e "s/CONFIG_HAMRADIO\(.*\)=./# CONFIG_HAMRADIO\1 is not set/" \
    -e "s/CONFIG_ATM\(.*\)=./# CONFIG_ATM\1 is not set/" \
    -e "s/CONFIG_SMP\(.*\)=./# CONFIG_SMP\1 is not set/" \
    -e "s/CONFIG_PCI_NAMES\(.*\)=./# CONFIG_PCI_NAMES\1 is not set/" \
    -e "s/CONFIG_INPUT_JOYDEV\(.*\)=./# CONFIG_INPUT_JOYDEV\1 is not set/" \
    -e "s/CONFIG_ACPI\(.*\)=./# CONFIG_ACPI\1 is not set/" \
    -e "s/CONFIG_GAMEPORT\(.*\)=./# CONFIG_GAMEPORT\1 is not set/" \
    -e "s/CONFIG_IP_NF\(.*\)=./CONFIG_IP_NF\1=m/" \
    -e "s/# CONFIG_EMBEDDED is not set/CONFIG_EMBEDDED=y/" \
    -e "s/CONFIG_KALLSYMS=./# CONFIG_KALLSYMS is not set/" \
    -e "s/CONFIG_IOSCHED_AS=./# CONFIG_IOSCHED_AS is not set/" \
    $1 > .config.boot

mv .config.boot $1

