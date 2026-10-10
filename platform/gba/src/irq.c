#include "helpers.h"

typedef void (*InterruptHandler)(void);

// Original stored at 0x08028d88.
static void DummyHandler(void) {}

// Original stored at 0x08028d8c.
static void VBlankHandler(void) { /* TODO */ }

// Original stored at 0x083b005c.
static IWRAM_ARM void HBlankHandler(void) { /* TODO */ }

// Original stored at 0x08026844.
static void SerialHandler(void) { /* TODO */ }

// Lives in .data (non-const), so it ends up in EWRAM like the original at 0x0201fa14.
// In ROM, this lives at 0x083d0020.
InterruptHandler gInterruptTable[15] = {
    VBlankHandler,  // VBlank
    HBlankHandler,  // HBlank
    DummyHandler,   // VCount
    DummyHandler,   // Timer 0
    DummyHandler,   // Timer 1
    DummyHandler,   // Timer 2
    DummyHandler,   // Timer 3
    SerialHandler,  // Serial
    DummyHandler,   // DMA 0
    DummyHandler,   // DMA 1
    DummyHandler,   // DMA 2
    DummyHandler,   // DMA 3
    DummyHandler,   // Keypad
    DummyHandler,   // Game Pak
    DummyHandler,   // spare
};
