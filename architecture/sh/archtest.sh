
case "$ROCKCFG_SH_OPT" in
	sh|sh2|sh3|sh4) arch_machine="$ROCKCFG_SH_OPT" ;;
esac

arch_target="${arch_machine}-t2-linux-gnu"

