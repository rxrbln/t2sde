
case "$ROCKCFG_ARM_ENDIANESS" in
    EL)
    	arch_bigendian=no
	arch_target="arm-t2-linux-gnu" ;;
    EB)
    	arch_bigendian=yes
	arch_target="arm-t2-linux-gnu" ;;
esac
