# Disclaimer: this has been generated using Claude.

# ---- Project settings ----
TARGET    := main
BUILD_DIR := build

# All .c files in the project root. To add subdirectories later, extend this,
# e.g.: SRCS := $(wildcard *.c) $(wildcard src/*.c)
SRCS := $(wildcard src/*.c)

# ---- Toolchain ----
PREFIX  := arm-none-eabi-
CC      := $(PREFIX)gcc
OBJCOPY := $(PREFIX)objcopy
GBAFIX  := gbafix

ARCH    := -mthumb-interwork -mthumb
CFLAGS  := $(ARCH) -O2 -MMD -MP
LDFLAGS := $(ARCH) -specs=gba.specs

# ---- Derived files ----
OBJS := $(SRCS:%.c=$(BUILD_DIR)/%.o)
DEPS := $(OBJS:.o=.d)
ELF  := $(BUILD_DIR)/$(TARGET).elf
ROM  := $(BUILD_DIR)/$(TARGET).gba

# ---- Rules ----
.PHONY: all clean

all: $(ROM)

# elf -> raw binary -> fix header
$(ROM): $(ELF)
	$(OBJCOPY) -v -O binary $< $@
	$(GBAFIX) $@

# link
$(ELF): $(OBJS)
	$(CC) $(OBJS) $(LDFLAGS) -o $@

# compile (-MMD -MP generates .d files so header changes trigger rebuilds)
$(BUILD_DIR)/%.o: %.c
	@mkdir -p $(dir $@)
	$(CC) -c $< $(CFLAGS) -o $@

clean:
	rm -rf $(BUILD_DIR)

-include $(DEPS)