
case "$ROCKCFG_HPPA_BITS" in
    32)
	arch_machine=hppa
	arch_target="hppa-unknown-linux-gnu"
	arch_sizeof_char_p=4 ;; 
    64)
	arch_machine=hppa
	arch_target="hppa64-unknown-linux-gnu"
	arch_sizeof_char_p=8 ;;
esac

