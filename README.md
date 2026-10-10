# BKMBattles

Non-matching decompilation of the GBA game Butt-Ugly Martians: B.K.M. Battles. Specifically, the U.S.A. ROM.

## GBA

You will need to install [devkitARM](https://devkitpro.org/wiki/Getting_Started) to build the game. Follow the instructions in the linked guide. **Make sure to install the "GBA Development" component.**

You will then need to add the folders containing the developer binaries to your PATH environment variable (in the newly-installed MSYS2 shell, if you are on Windows). On Windows, using the default installation path, this will be:

```bash
export PATH="/opt/devkitpro/tools/bin:/opt/devkitpro/devkitARM/bin:$PATH"
```

- `/opt/devkitpro/devkitARM/bin` (`C:\devkitPro\devkitARM\bin` in a default installation) (contains the compiler and linker, etc.).
- `/opt/devkitpro/tools/bin` (`C:\devkitPro\tools\bin` in a default installation) (contains GBA-specific tooling, e.g. `gbafix`).

You can then navigate to the root folder of this repository (using your MSYS2 terminal if you are on Windows), issue the `make` command, and then you can run the resulting `*.gba` file written within the [new] `build/gba` folder!
