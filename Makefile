# Disclaimer: this has been generated using Claude.

# ---- Project settings ----
TARGET    := main
PLATFORM  ?= gba
BUILD_DIR := build/$(PLATFORM)

# ---- Source layout ----
#   include/                      platform-neutral interface headers (declarations only)
#   src/                          platform-neutral game code
#   platform/<name>/include/      that platform's types (platform_types.h) and any internal header files
#   platform/<name>/src/          that platform's implementation of the interface
#   platform/<name>/platform.mk   toolchain, flags, and how to produce the final output
#
# Select a platform with: make PLATFORM=<name>   (default: gba)

# Recursive wildcard: $(call rwildcard,<dir>,*.c)
rwildcard = $(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))

PLATFORM_DIR := platform/$(PLATFORM)

SRCS_C := $(call rwildcard,src,*.c) $(call rwildcard,$(PLATFORM_DIR)/src,*.c)
SRCS_S := $(call rwildcard,$(PLATFORM_DIR)/src,*.s)
INCS   := include $(PLATFORM_DIR)/include

OBJS := $(SRCS_C:%.c=$(BUILD_DIR)/%.o) $(SRCS_S:%.s=$(BUILD_DIR)/%.o)
DEPS := $(OBJS:.o=.d)
ELF  := $(BUILD_DIR)/$(TARGET).elf

# Per-platform settings. Must define: CC, PLATFORM_CFLAGS, PLATFORM_ASFLAGS, PLATFORM_LDFLAGS, OUTPUT
# (and a rule that builds OUTPUT from $(ELF), unless OUTPUT is $(ELF) itself).
include $(PLATFORM_DIR)/platform.mk

CFLAGS  := $(PLATFORM_CFLAGS) $(addprefix -I,$(INCS)) -MMD -MP
ASFLAGS := $(PLATFORM_ASFLAGS)

# ---- Rules ----
.DEFAULT_GOAL := all
.PHONY: all clean

all: $(OUTPUT)

# link
$(ELF): $(OBJS)
	@mkdir -p $(dir $@)
	$(CC) $(OBJS) $(PLATFORM_LDFLAGS) -o $@

# compile (-MMD -MP generates .d files so header changes trigger rebuilds)
$(BUILD_DIR)/%.o: %.c
	@mkdir -p $(dir $@)
	$(CC) -c $< $(CFLAGS) -o $@

# assemble
$(BUILD_DIR)/%.o: %.s
	@mkdir -p $(dir $@)
	$(CC) -c $< $(ASFLAGS) -o $@

clean:
	rm -rf build

-include $(DEPS)
