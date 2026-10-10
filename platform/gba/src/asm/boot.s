@ Boot code.
    .section .text.start, "ax", %progbits
    .arm
    .global _start
_start:
    b       rom_start               @ 0x000: entry point
    .space  0xBC                    @ 0x004-0x0BF: header (gbafix fills in the logo and checksum)
    b       rom_start               @ 0x0C0: multiboot entry
    .space  0x1C                    @ 0x0C4-0x0DF: multiboot fields, unused
rom_start:                          @ 0x0E0
    mov     r0, #0x12               @ IRQ mode
    msr     cpsr_cf, r0
    ldr     sp, =0x03007FA0         @ IRQ stack
    mov     r0, #0x1f               @ System mode
    msr     cpsr_cf, r0
    ldr     sp, =0x03007F00         @ system/user stack
    add     r0, pc, #1              @ address of the Thumb code below, with bit 0 set
    bx      r0
    .thumb
    @ Point the BIOS IRQ vector at our handler. It lives in IWRAM and isn't copied
    @ until below, but interrupts are still disabled (IME = 0), so this is safe.
    ldr     r1, =0x03007FFC
    ldr     r0, =irq_handler        @ Original ROM: =0x030000f0
    str     r0, [r1, #0x0]

    @ Moves the ROM into EWRAM if we are in multiboot mode (i.e. the game wasn't linked at 0x08000000).
    @ Typical execution will always branch at the bcs instruction. This code block is included for completeness.
    ldr     r0, =0x08000000
    lsl     r0, r0, #0x5
    bcs     clear_ewram
    @ Are we already running from EWRAM? If so, there is nothing to copy, so skip straight to clearing IWRAM.
    mov     r0, pc
    lsl     r0, r0, #0x5
    bcc     clear_iwram
    @ We aren't running from EWRAM! Copy the ROM into EWRAM and then continue execution from there.
    mov     r3, #0x40
    lsl     r3, r3, #0xc           @ 0x40000 bytes
    lsl     r2, r3, #0x7           @ DMA3 dest = 0x02000000
    add     r6, r2, #0x0           @ Branch to 0x02000000 afterwards
    lsl     r1, r2, #0x2           @ DMA3 src = 0x08000000
    bl      copyMemoryViaDma3
    bx      r6

clear_ewram:
    mov     r1, #0x40
    lsl     r1, r1, #0xc
    lsl     r0, r1, #0x7
    bl      clearMemoryViaDma3

clear_iwram:
    mov     r0, #0x3
    lsl     r0, r0, #0x18
    ldr     r1, =0x00007e00
    bl      clearMemoryViaDma3

    @ Redundant but faithful to the original boot code.
    ldr     r0, =__bss_start
    ldr     r1, =__bss_end
    sub     r1, r1, r0
    bl      clearMemoryViaDma3

    @ Copy 0x083cdb80-0x083d0060 (0x24E0/9440 bytes) into EWRAM.
    @ See extraction1.bin.
    @ In the original game, this copies the last 0x24e0 bytes of the EWRAM image in the ROM.
    @ As you can see further down, another copy is carried out, this time of the entire EWRAM image.
    @ The two copies align exactly, so the smaller one is redundant,
    @ and so is being commented out in this implementation.
    @ ldr     r1, =0x083cdb80  @ __ewram_lma
    @ ldr     r2, =0x0201d574  @ __ewram_start
    @ ldr     r4, =0x0201fa54  @ __ewram_end
    @ bl      copyMemoryViaDma3IfNonEmpty

    @ Copy the ROM's IWRAM image into IWRAM.
    ldr     r1, =__iwram_lma    @ Original ROM: 0x083aea3c
    ldr     r2, =__iwram_start  @ Original ROM: 0x030000f0
    ldr     r4, =__iwram_end    @ Original ROM: 0x03001cc0
    bl      copyMemoryViaDma3IfNonEmpty

@ This game doesn't perform this copy due to the skip condition:
@ included as commented-out code for completeness.
@     ldr     r2, =0x083b060c
@     ldr     r1, =0x083b060c
@     sub     r3, r2, r1
@     beq     skipCopy1
@     ldr     r2, =0x0300482c
@     bl      copyMemoryViaDma3
@ skipCopy1:

    @ Copy the ROM's EWRAM image into EWRAM.
    ldr     r1, =__ewram_lma    @ Original ROM: 0x083b060c
    ldr     r2, =__ewram_start  @ Original ROM: 0x02000000
    ldr     r4, =__ewram_end    @ Original ROM: 0x0201fa54
    bl      copyMemoryViaDma3IfNonEmpty

@ This game doesn't perform this copy due to the skip condition:
@ included as commented-out code for completeness.
@     ldr     r2, =0x083cdb80
@     ldr     r1, =0x083cdb80
@     sub     r3, r2, r1
@     beq     skipCopy2
@     ldr     r2, =0x0201fa54
@     bl      copyMemoryViaDma3
@ skipCopy2:

    @ Invoke main().
    @ Leaving Thumb main() into ARM rom_start() works because of the -mthumb-interwork flag.
    mov     r0, #0x0
    mov     r1, #0x0
    ldr     r3, =rom_start
    mov     lr, r3
    ldr     r3, =main
    bx      r3
    @ Now whenever main() exits, rom_start is invoked again.

    .thumb_func
copyMemoryViaDma3IfNonEmpty:
    @ This operation sets the Z flag if r4 == r2. So we only perform the copy if the byte count is non-zero,
    @ and we use it in the subsequent copy operation. r4 is the end address and r2 is the start address.
    sub     r3, r4, r2
    beq     copyMemoryViaDma3_return
    .thumb_func
copyMemoryViaDma3:
    ldr     r0, =0x040000D0
    lsr     r3, r3, #0x2
    str     r1, [r0, #0x4]  @ DMA3 source address = r1
    str     r2, [r0, #0x8]  @ DMA3 destination address = r2
    strh    r3, [r0, #0xc]  @ DMA3 word count = r3 (was bytes, now converted to words)
    ldr     r3, =0x8400
    strh    r3, [r0, #0xe]  @ Initiate copy
copyMemoryViaDma3_return:
    bx      lr

    .thumb_func
clearMemoryViaDma3:
    cmp     r1, #0x0
    beq     clearMemoryViaDma3_return
    ldr     r2, =0x040000D0
    lsr     r1, r1, #0x2
    adr     r3, zero_word
    str     r3, [r2, #0x4]  @ DMA3 source address now points to 0x00
    str     r0, [r2, #0x8]  @ DMA3 destination address = r0
    strh    r1, [r2, #0xc]  @ DMA3 word count = r1 (was bytes, now converted to words)
    ldr     r1, =0x8500
    strh    r1, [r2, #0xe]  @ Initiate clear
clearMemoryViaDma3_return:
    bx      lr
    .align 2   @ Thumb adr needs a word-aligned target
zero_word:
    .word   0

    .pool
