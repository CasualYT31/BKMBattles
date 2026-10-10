#include <settings.h>

#include "helpers.h"

// Keep these uninitialized so that they end up in .bss (i.e. IWRAM).
SfxVolume gSfxVolume;      // 0x0300208d
MusicVolume gMusicVolume;  // 0x0300208e
Brightness gBrightness;    // 0x0300208f

void setAudioOn(bool onOrOff) { IO_SOUND_CONTROL_X = onOrOff ? 0x80 : 0x00; }

void setSfxVolume(SfxVolume volume) { gSfxVolume = volume; }

SfxVolume getSfxVolume(void) { return gSfxVolume; }

void setMusicVolume(MusicVolume volume) { gMusicVolume = volume; }

MusicVolume getMusicVolume(void) { return gMusicVolume; }

void setBrightness(Brightness newSetting) { gBrightness = newSetting; }

Brightness getBrightness(void) { return gBrightness; }
