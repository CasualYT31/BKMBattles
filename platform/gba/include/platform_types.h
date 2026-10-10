/**
 * @file platform_types.h
 * If you want to add support for another platform, your platform must define the following typedefs in a header that
 * shares its name with this one. Then when you select your platform when building the game, its typedefs will be pulled
 * from its `platform_types.h` header.
 */

#ifndef GBA_PLATFORM_TYPES
#define GBA_PLATFORM_TYPES

#include <stdint.h>

// Stores an input bit mask.
typedef uint16_t ButtonMask;

// Stores an SFX volume.
typedef uint8_t SfxVolume;

// Store a music volume.
typedef uint8_t MusicVolume;

// Store a brightness setting.
typedef uint8_t Brightness;

#endif  // GBA_PLATFORM_TYPES
