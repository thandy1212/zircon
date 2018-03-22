# Copyright 2018 The Fuchsia Authors
#
# Use of this source code is governed by a MIT-style
# license that can be found in the LICENSE file or at
# https://opensource.org/licenses/MIT

LOCAL_DIR := $(GET_LOCAL_DIR)

PLATFORM := generic-arm


MODULE := $(LOCAL_DIR)


LEGACY_HEADER_SRC := $(LOCAL_DIR)/legacy-header.S
LEGACY_HEADER_OBJ := $(BUILDDIR)/legacy-header.o
LEGACY_HEADER_BIN := $(BUILDDIR)/legacy-header.bin

$(LEGACY_HEADER_OBJ): $(LEGACY_HEADER_SRC)
	@$(MKDIR)
	$(call BUILDECHO, compiling $<)
	$(NOECHO)$(CC) -Ikernel/arch/arm64/include -Isystem/public -c $< -MMD -MP -MT $@ -MF $(@:%o=%d) -o $@

$(LEGACY_HEADER_BIN): $(LEGACY_HEADER_OBJ)
	$(call BUILDECHO,generating $@)
	$(NOECHO)$(OBJCOPY) -O binary $< $@

GENERATED += $(LEGACY_HEADER_BIN)


# prepend legacy header to kernel image
LEGACY_KERNEL_IMAGE := $(BUILDDIR)/legacy-zircon.bin

$(LEGACY_KERNEL_IMAGE): $(LEGACY_HEADER_BIN) $(OUTLKBIN)
	$(NOECHO)cat $(LEGACY_HEADER_BIN) $(OUTLKBIN) > $(LEGACY_KERNEL_IMAGE)

EXTRA_KERNELDEPS += $(LEGACY_KERNEL_IMAGE)

# Some boards need gzipped kernel image
OUT_ZIRCON_ZIMAGE := $(BUILDDIR)/z$(LKNAME).bin

$(OUT_ZIRCON_ZIMAGE): $(OUTLKBIN)
	$(call BUILDECHO,gzipping image $@)
	$(NOECHO)gzip -c $< > $@

GENERATED += $(OUT_ZIRCON_ZIMAGE)
EXTRA_BUILDDEPS += $(OUT_ZIRCON_ZIMAGE)

GENERATED += $(OUT_ZIRCON_ZIMAGE)
EXTRA_BUILDDEPS += $(OUT_ZIRCON_ZIMAGE)

# include rules for our various arm64 boards
include $(LOCAL_DIR)/*/rules.mk
