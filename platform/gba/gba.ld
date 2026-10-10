/* platform/gba/gba.ld -- GBA linker script for a hand-written boot sequence. Generated with Claude. */
OUTPUT_FORMAT("elf32-littlearm")
OUTPUT_ARCH(arm)
ENTRY(_start)

MEMORY
{
    rom   (rx)  : ORIGIN = 0x08000000, LENGTH = 32M
    ewram (rwx) : ORIGIN = 0x02000000, LENGTH = 256K
    iwram (rwx) : ORIGIN = 0x03000000, LENGTH = 32K
}

SECTIONS
{
    /* Boot code first: the ROM header lives at the very start of .text.start */
    .text : {
        KEEP(*(.text.start))
        *(.text .text.*)
        *(.rodata .rodata.*)
        *(.glue_7 .glue_7t)
        . = ALIGN(4);
    } > rom

    /* IWRAM code and initialised data: stored in ROM, copied by boot.s */
    .iwram : {
        __iwram_start = .;
        *(.iwram .iwram.*)
        . = ALIGN(4);
        __iwram_end = .;
    } > iwram AT> rom
    __iwram_lma = LOADADDR(.iwram);

    /* IWRAM zero-initialised data: cleared by boot.s */
    .bss (NOLOAD) : {
        . = ALIGN(4);
        __bss_start = .;
        *(.bss .bss.*)
        *(COMMON)
        . = ALIGN(4);
        __bss_end = .;
    } > iwram
    __iwram_and_bss_end = .;

    /* EWRAM initialised data: stored in ROM, copied by boot.s */
    .ewram : {
        __ewram_start = .;
        *(.ewram .ewram.*)
        *(.data .data.*)
        . = ALIGN(4);
        __ewram_end = .;
    } > ewram AT> rom
    __ewram_lma = LOADADDR(.ewram);

    /* EWRAM zero-initialised data: boot.s clears all of EWRAM, so no symbols needed */
    .sbss (NOLOAD) : {
        *(.sbss .sbss.*)
        . = ALIGN(4);
    } > ewram

    /DISCARD/ : { *(.ARM.exidx*) *(.comment) *(.note*) }
}

/* The user stack grows down from 0x03007F00; keep some room for it. Tune as needed. */
ASSERT(__iwram_and_bss_end <= 0x03007F00 - 0x800, "IWRAM data overlaps the stack")
