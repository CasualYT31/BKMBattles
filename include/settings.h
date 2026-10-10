#ifndef INTERFACE_SETTINGS_HEADER
#define INTERFACE_SETTINGS_HEADER

#include <stdbool.h>

#include "platform_types.h"

void setAudioOn(bool onOrOff);

void setSfxVolume(SfxVolume volume);

SfxVolume getSfxVolume(void);

void setMusicVolume(MusicVolume volume);

MusicVolume getMusicVolume(void);

void setBrightness(Brightness newSetting);

Brightness getBrightness(void);

#endif  // INTERFACE_SETTINGS_HEADER
