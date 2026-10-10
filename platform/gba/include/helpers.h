#ifndef GBA_HELPERS_HEADER
#define GBA_HELPERS_HEADER

#include <stdint.h>

// MARK: Attributes

// Prepend function definitions with this macro to run the function in ARM mode.
// By default, everything is run in Thumb mode.
#define ARM __attribute__((target("arm")))

// Compile a function into ARM, and also execute it from the faster IWRAM.
#define IWRAM_ARM __attribute__((section(".iwram.text"), target("arm")))

// Data in EWRAM. Initialised: copied from ROM at boot.
#define EWRAM_DATA __attribute__((section(".ewram")))

// Data in EWRAM. Zero-initialised: takes no ROM space (boot.s clears all of EWRAM).
#define EWRAM_BSS __attribute__((section(".sbss")))

// Data in IWRAM. Initialised: copied from ROM at boot.
#define IWRAM_DATA __attribute__((section(".iwram.data")))

// MARK: Memory

#define BYTE_AT(B, O) (*(volatile uint8_t*)((B) + (O)))
#define HALFWORD_AT(B, O) (*(volatile uint16_t*)((B) + (O)))
#define WORD_AT(B, O) (*(volatile uint32_t*)((B) + (O)))

// MARK: I/O Map

#define IO_BASE 0x04000000

#define IO_GENERAL_LCD_STATUS HALFWORD_AT(IO_BASE, 0x4)

#define IO_DMA_3_SRC_ADDR WORD_AT(IO_BASE, 0xd4)
#define IO_DMA_3_DEST_ADDR WORD_AT(IO_BASE, 0xd8)
#define IO_DMA_3_WORD_COUNT HALFWORD_AT(IO_BASE, 0xdc)
#define IO_DMA_3_CONTROL HALFWORD_AT(IO_BASE, 0xde)
#define IO_DMA_3_WORD_COUNT_AND_CONTROL WORD_AT(IO_BASE, 0xdc)

#define IO_SOUND_CONTROL_X HALFWORD_AT(IO_BASE, 0x84)
#define IO_SOUND_PWM_CONTROL HALFWORD_AT(IO_BASE, 0x88)

#define IO_TIMER_0_COUNTER_AND_CONTROL WORD_AT(IO_BASE, 0x100)

#define IO_KEYPAD_INPUT HALFWORD_AT(IO_BASE, 0x130)

#define IO_INTERRUPT_ENABLE HALFWORD_AT(IO_BASE, 0x200)
#define IO_INTERRUPT_REQ_FLAGS HALFWORD_AT(IO_BASE, 0x202)
#define IO_GAME_PAK_WAITSTATE_CONTROL HALFWORD_AT(IO_BASE, 0x204)
#define IO_INTERRUPT_MASTER_ENABLE HALFWORD_AT(IO_BASE, 0x208)

// MARK: Buttons

#define A_BUTTON 0x1
#define B_BUTTON 0x2
#define SELECT_BUTTON 0x4
#define START_BUTTON 0x8
#define RIGHT_BUTTON 0x10
#define LEFT_BUTTON 0x20
#define UP_BUTTON 0x40
#define DOWN_BUTTON 0x80
#define R_BUTTON 0x100
#define L_BUTTON 0x200
#define ALL_BUTTONS 0x3ff

#endif  // GBA_HELPERS_HEADER
