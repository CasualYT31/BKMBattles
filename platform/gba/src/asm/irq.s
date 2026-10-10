@ Interrupt handler (copied to IWRAM).
@ For individual interrupt handlers, see their C implementations in irq.c.
.syntax unified

@ ---------------------------------------------------------------------------
@ Handler. The BIOS calls it in ARM mode via the pointer at 0x03007FFC.
@ Lets other interrupts interrupt it (nested interrupts), as the original does.
@ Stored at 0x083aea3c in the original ROM, and originally executes from 0x030000f0.
@ ---------------------------------------------------------------------------
    .section .iwram, "ax", %progbits
    .arm
    .align 2
    .global irq_handler
irq_handler:
    mov     r2, #0x04000000
    @ Reads the interrupt enable register (IE) and the interrupt request flags (which interrupts were raised).
    ldr     r3, [r2, #0x200]!  @ r2 = 0x04000200
    @ Reads the interrupt master enable register (IME).
    ldrh    r1, [r2, #8]
    @ Retain the Saved Program Status Register's value.
    mrs     r0, spsr
    @ Pushes it, the IME, the IE pointer, and the link register to the stack.
    stmdb   sp!, {r0-r2, lr}

    mov     r0, #1
    @ IME = 1 (allows for nested interrupts later on).
    strh    r0, [r2, #8]
    @ r1 = r3 & (r3 >> 16).
    @ Figures out which interrupts are both enabled and raised.
    and     r1, r3, r3, lsr #0x10
    @ Load the address to the table of interrupt handlers.
    ldr     r12, =gInterruptTable

    @ Find the first raised interrupt, VBlank first; r12 ends up on its table slot.
    @   Bit   Expl.
    @   0     LCD V-Blank
    @   1     LCD H-Blank
    @   2     LCD V-Counter Match
    @   3     Timer 0 Overflow
    @   4     Timer 1 Overflow
    @   5     Timer 2 Overflow
    @   6     Timer 3 Overflow
    @   7     Serial Communication
    @   8     DMA 0
    @   9     DMA 1
    @   10    DMA 2
    @   11    DMA 3
    @   12    Keypad
    @   13    Game Pak (external IRQ source)
    @   14-15 Not used
    .irp bit, 0x0001,0x0002,0x0004,0x0008,0x0010,0x0020,0x0040,0x0080,0x0100,0x0200,0x0400,0x0800,0x1000
    ands    r0, r1, #\bit
    bne     irq_found
    add     r12, r12, #4
    .endr

    @ Checks if the Game Pak has been removed.
    ands    r0, r1, #0x2000
    @ If it has, write the low byte of 0x2000 to 0x04000084 (SOUNDCNT_X).
    @ This effectively turns sound off (0x00).
    strbne  r0, [r2, #-0x17C]
    @ Also, if it has, loop infinitely until the console is powered off or reset.
    bne     .
    @ Otherwise, execution continues with r0 = 0 and r12 = slot 13

irq_found:
    @ Write the interrupt bit back to the flag (0x04000202) to ACK it.
    strh    r0, [r2, #2]

    @ Pull the Current Program Status Register.
    mrs     r3, cpsr
    @ r3 = r3 & ~0xdf. Clears the IRQ and FIQ disable bits, and the mode, but keeps the Thumb bit and condition flags.
    bic     r3, r3, #0xDF
    @ Turns on system mode.
    orr     r3, r3, #0x1F
    @ Applies the flags and control bits to the CPSR.
    msr     cpsr_fc, r3
    @ Load the address to the interrupt handler.
    ldr     r0, [r12]
    @ Save the link register that belongs to system mode and tell the CPU to return to the ldmia instruction.
    stmdb   sp!, {lr}
    add     lr, pc, #0
    @ Invoke the handler.
    bx      r0

    @ Restore the link register that previously belonged to system mode before invoking the handler.
    ldmia   sp!, {lr}
    @ Restore IRQ mode, but disable IRQs.
    mrs     r3, cpsr
    bic     r3, r3, #0xDF
    orr     r3, r3, #0x92
    msr     cpsr_fc, r3
    @ Restores the SPSR, the IME, the IE pointer, and the link register from the stack.
    ldmia   sp!, {r0-r2, lr}
    @ Applies the restored IME value.
    strh    r1, [r2, #8]
    @ Reapply the SPSR.
    msr     spsr_fc, r0
    @ Return to the BIOS, which restores r0-r3, r12, lr, and then resumes the code that was interrupted.
    bx      lr
    .pool
