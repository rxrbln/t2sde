
case "$ROCKCFG_MIPS_ENDIANESS" in
    EL)
    	arch_bigendian=no
	arch_target="mipsel-t2-linux-gnu" ;;
    EB)
    	arch_bigendian=yes
	arch_target="mips-t2-linux-gnu" ;;
esac
