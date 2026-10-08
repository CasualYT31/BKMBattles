# BKMBattles

Non-matching decompilation of the GBA game Butt-Ugly Martians: B.K.M. Battles.

## Prerequisites

You will need to install [devkitARM](https://devkitpro.org/wiki/Getting_Started) to build the game. Follow the instructions in the linked guide. **Make sure to install the "GBA Development" component.**

You will then need to add the folders containing the developer binaries to your PATH environment variable (in the newly-installed MSYS shell, if you are on Windows). On Windows, using the default installation path, this will be:

```bash
export PATH="/c/devkitPro/tools/bin:/c/devkitPro/devkitARM/bin:$PATH"
```

- `C:\devkitPro\devkitARM\bin` (contains the compiler and linker, etc.).
- `C:\devkitPro\tools\bin` (contains GBA-specific tooling, e.g. `gbafix`).

## Building

You can then navigate to the root folder of this repository (using your MSYS terminal if you are on Windows), issue the `make` command, and then you can run the resulting `*.gba` file written within the [new] `build` folder!
