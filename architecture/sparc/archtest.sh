
case "$ROCKCFG_SPARC_BITS" in
    32)
	arch_machine=sparc
	arch_target="sparc-unknown-linux-gnu"
	arch_sizeof_char_p=4 ;; 
    64)
	arch_machine=sparc64
	arch_target="sparc64-unknown-linux-gnu"
	arch_sizeof_char_p=8 ;;
esac

