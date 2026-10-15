/* link.ld - tells the linker where to put the code
   instruction memory starts at address 0, so the code goes there
   start.S goes first so _start is the first instruction the cpu runs */

ENTRY(_start)

SECTIONS
{
    . = 0x0;

    .text : {
        *(.text.start)
        *(.text*)
    }
}
