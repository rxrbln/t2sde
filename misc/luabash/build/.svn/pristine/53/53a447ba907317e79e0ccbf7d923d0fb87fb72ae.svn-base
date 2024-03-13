OUTPUT_FORMAT(binary)
SECTIONS {
    . = 0x0100;
    .start : {
	*(.start);
     }
    .text : {
        *(.text);
    }
    .data : {
        *(.data);
        *(.bss);
        *(.rodata);
    }
    _heap = ALIGN(4);
}
