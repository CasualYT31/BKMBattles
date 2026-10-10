#ifndef INTERFACE_INOUT_HEADER
#define INTERFACE_INOUT_HEADER

#include "platform_types.h"

/**
 * Checks to see if all of the given buttons are currently being pressed.
 * \param mask A collection of button bits. 1 means the button must be pressed, 0 means it is ignored in the check.
 * \return 0 if not every specified button is being pressed, 1 if they are. 1 is always returned if 0 is given.
 */
int areButtonsPressed(ButtonMask mask);

#endif  // INTERFACE_INOUT_HEADER
