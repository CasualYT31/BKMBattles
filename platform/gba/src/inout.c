#include <inout.h>

#include "helpers.h"

int areButtonsPressed(const ButtonMask mask) { return ((IO_KEYPAD_INPUT ^ ALL_BUTTONS) & mask) == mask; }
