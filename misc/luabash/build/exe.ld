OUTPUT_FORMAT(binary)
SECTIONS {
    .sig : {
	SHORT(0x5a4d); /* magic */
	SHORT(262); /* last page size */

	SHORT(0x0007); /* file pages */
	SHORT(0x0000); /* relocation items */

	SHORT(16); /* header paragraphs, 16 for .com */
	SHORT(1); /* min alloc */

	SHORT(1); /* max alloc */
	SHORT(0); /* initial SS */

	SHORT(0xfffe); /* initial SP */
	SHORT(0); /* checksum */

	SHORT(0x00); /* initial IP */
	SHORT(0); /* initial CS */

	SHORT(0x100); /* relocation table offset */
	SHORT(0); /* overlay number */
    }

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
