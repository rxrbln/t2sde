
case "$ROCKCFG_X86_OPT" in
    i?86)
	arch_machine="$ROCKCFG_X86_OPT" ;;

    pentium|pentium-mmx|k6*)
	arch_machine="i586" ;;

    pentium*|athlon*)
	arch_machine="i686" ;;
esac

arch_target="${arch_machine}-t2-linux-gnu"

