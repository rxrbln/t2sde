
case "$ROCKCFG_MIPS_ENDIANESS" in
    EL)
    	arch_bigendian=no
	arch_target="mipsel-unknown-linux-gnu" ;;
    EB)
    	arch_bigendian=yes
	arch_target="mips-unknown-linux-gnu" ;;
esac
