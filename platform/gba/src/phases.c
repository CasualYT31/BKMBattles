#include <inout.h>
#include <phases.h>
#include <settings.h>

#include "helpers.h"

EWRAM_BSS uint8_t gUnknown_020196bc = 0;   // 0x020196bc
EWRAM_BSS uint16_t gUnknown_0201fa10 = 0;  // 0x0201fa10

// It is suspected that this stores the RNG seed.
// The RNG code (and thus the seed itself) were likely hand-written/-stored in ASM as they live right next to each other
// in the ROM's IWRAM image. Because of this, technically, this global is initialized from ROM in the original game. But
// since it's initialized to 0x0, behaviourally it's the same as if it belonged in the .bss section (and thus was not
// initialized from ROM, but zero-initialized).
uint32_t gUnknown_030017e0;  // 0x030017e0 (= 0x083b012c)

uint32_t gUnknown_03001d70;  // 0x03001d70
uint16_t gUnknown_03001d74;  // 0x03001d74
uint8_t gUnknown_0300208c;   // 0x0300208c
uint8_t gUnknown_03002091;   // 0x03002091
uint16_t gUnknown_030031c8;  // 0x030031c8

static void testProgram(void) {
    // Write into the I/O registers, setting video display parameters.
    volatile unsigned char* ioram = (unsigned char*)0x04000000;
    ioram[0] = 0x03;  // Use video mode 3 (in BG2, a 16bpp bitmap in VRAM)
    ioram[1] = 0x04;  // Enable BG2 (BG0 = 1, BG1 = 2, BG2 = 4, ...)

    // Write pixel colours into VRAM
    volatile unsigned short* vram = (unsigned short*)0x06000000;
    vram[80 * 240 + 115] = 0x001F;  // X = 115, Y = 80, C = 000000000011111 = R
    vram[80 * 240 + 120] = 0x03E0;  // X = 120, Y = 80, C = 000001111100000 = G
    vram[80 * 240 + 125] = 0x7C00;  // X = 125, Y = 80, C = 111110000000000 = B
}

// It does a lot stuff with IWRAM that I don't know the meaning of yet.
// Come back to this once I figure out what those structs are storing and how they are formatted.
static void unknown_0800551c(void) {
    /* 0x0800551c - 0x08005522: Not sure what any of this does yet so keep it commented out for now.

    // r0 = 0x08028e81

    // r1 = 0x08028ea1

    // ---

    // r3 = 0x080016a5

    // TODO: what tf is FUN_00000cc4 doing?

    IO_DMA_3_SRC_ADDR = 0x080016a5;
    IO_DMA_3_DEST_ADDR = 0x03000000;
    // Enable, 32-bits, destination and source addresses increment, start immediately.
    IO_DMA_3_WORD_COUNT_AND_CONTROL = 0x84000038;  // 224 bytes copied.
    // This now reads back 0x04000000, but the value is immediately dropped.
    // const uint32_t wordCountAndControl = IO_DMA_3_WORD_COUNT_AND_CONTROL;

    volatile uint32_t spLocal = 0x0;
    IO_DMA_3_SRC_ADDR = (uint32_t)(&spLocal);
    IO_DMA_3_DEST_ADDR = 0x030031cc;
    // Enable, 32-bits, destination address increments, start immediately.
    IO_DMA_3_WORD_COUNT_AND_CONTROL = 0x8500000c;

    spLocal = 0x0;
    IO_DMA_3_SRC_ADDR = (uint32_t)(&spLocal);
    IO_DMA_3_DEST_ADDR = 0x030045b4;
    // Enable, 32-bits, destination address increments, start immediately.
    IO_DMA_3_WORD_COUNT_AND_CONTROL = 0x85000070;

    spLocal = 0x0;
    IO_DMA_3_SRC_ADDR = (uint32_t)(&spLocal);
    IO_DMA_3_DEST_ADDR = 0x03004774;
    // Enable, 32-bits, destination address increments, start immediately.
    IO_DMA_3_WORD_COUNT_AND_CONTROL = 0x85000002;

    *0x030031cc = 0x080013e9;
    *0x030047c8 = 0x08028e81;  // = r0 parameter
    *0x030047cc = 0x08028ea1;  // = r1 parameter

    */

    // uint32_t r2 = 0x90;
    // uint32_t r1 = 0x2910;
    // uint32_t r0 = 0x0;

    // Function call.

    // uint32_t r5 = r0;
    // uint32_t r6 = r1;
    // uint32_t r4 = r2;

    // Function call.

    setAudioOn(false);

    // Clears the function pointer we just assigned earlier....
    // *0x030031cc = 0x0;

    // Copying that partial code buffer in again....
    // IO_DMA_3_SRC_ADDR = 0x080016a5;
    // IO_DMA_3_DEST_ADDR = 0x03000000;
    // // Enable, 16-bits, destination and source addresses increment, start immediately.
    // IO_DMA_3_WORD_COUNT_AND_CONTROL = 0x80000070;  // 224 bytes copied.
    // // This now reads back, but the value is immediately dropped.
    // // const uint32_t wordCountAndControl = IO_DMA_3_WORD_COUNT_AND_CONTROL;

    IO_TIMER_0_COUNTER_AND_CONTROL = 0x0;

    // Return.

    // uint32_t one = 0x1;
    // uint32_t structPtr = 0x03003cfc;
    // for (uint32_t r1 = 0x0; r1 <= 0x11; ++r1) {
    //     *structPtr = one;
    //     structPtr += 0x7c;
    // }

    // Sets the final sound output settings to their default.
    IO_SOUND_PWM_CONTROL = 0x200;

    // + 0x20 into 31cc struct.
    // *0x030031ec = r4;

    // Function call, r0 = r5

    // uint32_t romAddress = r5 == 0x0 ? 0x080013E9 : 0x08001459;

    // + 0x24 into 31cc struct.
    // *0x030031f0 = romAddress;

    // if ((*0x030031cc) & 0x1) {
    //     //
    // }

    // ... lots more code.

    // Return.

    // ... lots more code.

    // Return.
}

void setUp(void) {
    // Not sure what this is doing... This value is already 0 in the debugger when I checked.
    if (areButtonsPressed(A_BUTTON | B_BUTTON | SELECT_BUTTON | START_BUTTON)) {
        gUnknown_0201fa10 = 0x0;
    }

    IO_GAME_PAK_WAITSTATE_CONTROL = 0x4000;

    // TODO: move this IWRAM-based initialization to main.c once I figure out what each write is for and put them behind
    //       generic functions like I have for settings.

    gUnknown_03001d74 = 0x1f40;
    gUnknown_03001d70 = 0x0;

    gUnknown_03002091 = 0x0;
    gUnknown_0300208c = 0x1;

    // TODO: Would be nice to R/W from/to EEPROM :eyes:
    setBrightness(0x0);
    setSfxVolume(0xf);
    setMusicVolume(0xa);

    gUnknown_030017e0 = 0x14BBD416;

    gUnknown_030031c8 = 0x0;

    IO_INTERRUPT_MASTER_ENABLE = 0x1;
    // Enables VBlank, HBlank, VCount, DMA1, DMA2, and Game Pak interrupts.
    IO_INTERRUPT_ENABLE = 0x2607;
    // In the original code, but doesn't achieve anything.
    IO_INTERRUPT_REQ_FLAGS = 0x0;
    // Request an interrupt when VBlank starts, and request an interrupt when the current scanline equals 10.
    IO_GENERAL_LCD_STATUS = 0xa28;

    gUnknown_020196bc = 0x0;

    unknown_0800551c();

    // Test program that draws three RGB pixels to the screen.
    testProgram();

    // Wait forever.
    while (1);
}
