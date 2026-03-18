ROOT_DIR := $(shell pwd)
SRC_DIR := $(ROOT_DIR)/yuanshu-config
SKINS_DIR := $(ROOT_DIR)/yuanshu-skin
OUTPUT_DIR := $(ROOT_DIR)/yuanshu-output

# Default profile if none provided
PROFILE ?= my
PROFILE_FILE := yuanshu-profiles/$(PROFILE).mk

# Check if profile exists
ifeq ($(wildcard $(PROFILE_FILE)),)
$(error Profile $(PROFILE_FILE) does not exist! Create it first.)
endif

include $(PROFILE_FILE)

# Setup output directory for this profile
PROFILE_OUT := $(OUTPUT_DIR)/$(PROFILE)
PROFILE_SKINS_OUT := $(PROFILE_OUT)/skins

# ---------------------------------------------------------
# SMART DEPENDENCY MAPPING
# ---------------------------------------------------------

# Initialize lists
ROOT_YAML_FILES :=
ROOT_DIRS :=
SRC_YAML_FILES :=
SRC_DIRS :=
YUANSHU_SKINS :=

# Handle "all" keyword to automatically grab everything
ifeq ($(ROOT_SCHEMAS),all)
ROOT_SCHEMAS := $(patsubst $(ROOT_DIR)/%.schema.yaml,%,$(wildcard $(ROOT_DIR)/*.schema.yaml))
endif

ifeq ($(YUANSHU_SCHEMAS),all)
YUANSHU_SCHEMAS := $(patsubst $(SRC_DIR)/%.schema.yaml,%,$(wildcard $(SRC_DIR)/*.schema.yaml))
endif


# Map schemas to their base files and custom patches
$(foreach schema, $(ROOT_SCHEMAS), $(eval ROOT_YAML_FILES += $(schema).schema.yaml))
$(foreach schema, $(YUANSHU_SCHEMAS), $(eval SRC_YAML_FILES += $(schema).schema.yaml))
$(foreach schema, $(ROOT_SCHEMAS) $(YUANSHU_SCHEMAS), $(eval SRC_YAML_FILES += $(schema).custom.yaml))

# --- Dependency Rules ---

# Cangjie6
ifneq (,$(findstring cangjie6,$(ROOT_SCHEMAS) $(YUANSHU_SCHEMAS)))
	ROOT_YAML_FILES += cangjie6.dict.yaml cangjie6.extended.dict.yaml
endif

# Flypy
ifneq (,$(findstring flypy,$(ROOT_SCHEMAS) $(YUANSHU_SCHEMAS)))
	ROOT_YAML_FILES += flypy.yaml
endif

# Luna Pinyin
ifneq (,$(findstring luna_pinyin,$(ROOT_SCHEMAS) $(YUANSHU_SCHEMAS)))
	ROOT_YAML_FILES += luna_pinyin.dict.yaml zhuyin.yaml
endif

# Terra Pinyin
ifneq (,$(findstring terra_pinyin,$(ROOT_SCHEMAS) $(YUANSHU_SCHEMAS)))
	ROOT_YAML_FILES += terra_pinyin.dict.yaml
endif

# Jyut6ping3
ifneq (,$(findstring jyut6ping3,$(ROOT_SCHEMAS) $(YUANSHU_SCHEMAS)))
	ROOT_YAML_FILES += jyut6ping3.dict.yaml symbols_cantonese.yaml
	ROOT_DIRS += jyut6ping3_dicts
endif

# Rime Ice (used by both flypy_ice and shuffle17_ice)
ifneq (,$(findstring _ice,$(YUANSHU_SCHEMAS)))
	SRC_YAML_FILES += rime_ice.dict.yaml
	SRC_DIRS += rime_ice_dicts
endif

# Quadharmonic Skin (default for standard schemas)
ifneq (,$(filter-out shuffle17_ice,$(ROOT_SCHEMAS) $(YUANSHU_SCHEMAS)))
	YUANSHU_SKINS += quadharmonic
endif

# Shuffle17 Skin (triggered by shuffle17_ice schema)
ifneq (,$(findstring shuffle17_ice,$(YUANSHU_SCHEMAS)))
	YUANSHU_SKINS += shuffle17
endif



# Any extra dicts or files explicitly requested by the profile
ROOT_YAML_FILES += $(EXTRA_ROOT_FILES)
SRC_YAML_FILES += $(EXTRA_SRC_FILES)

# Deduplicate lists
ROOT_YAML_FILES := $(sort $(ROOT_YAML_FILES))
SRC_YAML_FILES := $(sort $(SRC_YAML_FILES))
ROOT_DIRS := $(sort $(ROOT_DIRS))
SRC_DIRS := $(sort $(SRC_DIRS))
YUANSHU_SKINS := $(sort $(YUANSHU_SKINS))

# --- Build Targets ---

SKIN_CSKINS := $(patsubst %,$(PROFILE_SKINS_OUT)/%.cskin,$(YUANSHU_SKINS))

BUILD_DEPS := copy-files $(SKIN_CSKINS) $(PROFILE_OUT)/default.custom.yaml
ifneq (,$(findstring cangjie5,$(ROOT_SCHEMAS) $(YUANSHU_SCHEMAS)))
BUILD_DEPS += $(PROFILE_OUT)/cangjie5.dict.yaml
endif

.PHONY: all clean build copy-files zip

all: all-profiles

clean:
	rm -rf $(OUTPUT_DIR)

build: $(BUILD_DEPS)

copy-files:
	@mkdir -p $(PROFILE_OUT)
	@if [ -n "$(ROOT_YAML_FILES)" ]; then \
		for file in $(ROOT_YAML_FILES); do \
			if [ -f "$(ROOT_DIR)/$$file" ]; then cp "$(ROOT_DIR)/$$file" "$(PROFILE_OUT)/"; fi; \
		done; \
	fi
	@if [ -n "$(SRC_YAML_FILES)" ]; then \
		for file in $(SRC_YAML_FILES); do \
			if [ -f "$(SRC_DIR)/$$file" ]; then cp "$(SRC_DIR)/$$file" "$(PROFILE_OUT)/"; fi; \
		done; \
	fi
	@if [ -n "$(ROOT_DIRS)" ]; then \
		for dir in $(ROOT_DIRS); do \
			if [ -d "$(ROOT_DIR)/$$dir" ]; then cp -R "$(ROOT_DIR)/$$dir" "$(PROFILE_OUT)/"; fi; \
		done; \
	fi
	@if [ -n "$(SRC_DIRS)" ]; then \
		for dir in $(SRC_DIRS); do \
			if [ -d "$(SRC_DIR)/$$dir" ]; then cp -R "$(SRC_DIR)/$$dir" "$(PROFILE_OUT)/"; fi; \
		done; \
	fi

# Explicit rule for Cangjie5 dict (awk patch)
$(PROFILE_OUT)/cangjie5.dict.yaml: $(ROOT_DIR)/cangjie5.dict.yaml
	@mkdir -p $(PROFILE_OUT)
	@awk '\
		/^use_preset_vocabulary:/ { print "use_preset_vocabulary: true"; seen_use=1; next } \
		/^max_phrase_length:/ { print "max_phrase_length: 7"; seen_max=1; next } \
		/^min_phrase_weight:/ { if (!seen_use) print "use_preset_vocabulary: true"; if (!seen_max) print "max_phrase_length: 7" } \
		{ print } \
	' $< > $@

# Auto-generate default.custom.yaml snippet based on requested schemas
$(PROFILE_OUT)/default.custom.yaml:
	@echo "patch:" > $@
	@echo "  schema_list:" >> $@
	@for schema in $(ROOT_SCHEMAS) $(YUANSHU_SCHEMAS); do \
		echo "    - schema: $$schema" >> $@; \
	done

# Skin compilation rule
$(PROFILE_SKINS_OUT)/%.cskin: $(SKINS_DIR)/% $(SKINS_DIR)/%/jsonnet/main.jsonnet
	@echo "Building skin for $(PROFILE): $*"
	@mkdir -p $(OUTPUT_DIR)/tmp-$(PROFILE)/build-$*/dark $(OUTPUT_DIR)/tmp-$(PROFILE)/build-$*/light $(OUTPUT_DIR)/tmp-$(PROFILE)/$* $(PROFILE_SKINS_OUT)
	@cp -R $(SKINS_DIR)/$*/* $(OUTPUT_DIR)/tmp-$(PROFILE)/$*/
	@jsonnet -m $(OUTPUT_DIR)/tmp-$(PROFILE)/build-$* $(SKINS_DIR)/$*/jsonnet/main.jsonnet >/dev/null
	@rm -rf $(OUTPUT_DIR)/tmp-$(PROFILE)/$*/dark $(OUTPUT_DIR)/tmp-$(PROFILE)/$*/light
	@cp -R $(OUTPUT_DIR)/tmp-$(PROFILE)/build-$*/dark $(OUTPUT_DIR)/tmp-$(PROFILE)/$*/
	@cp -R $(OUTPUT_DIR)/tmp-$(PROFILE)/build-$*/light $(OUTPUT_DIR)/tmp-$(PROFILE)/$*/
	@if [ -f "$(OUTPUT_DIR)/tmp-$(PROFILE)/build-$*/config.yaml" ]; then \
		cp $(OUTPUT_DIR)/tmp-$(PROFILE)/build-$*/config.yaml $(OUTPUT_DIR)/tmp-$(PROFILE)/$*/config.yaml; \
	fi
	@cd $(OUTPUT_DIR)/tmp-$(PROFILE) && zip -qr $@ $*
	@rm -rf $(OUTPUT_DIR)/tmp-$(PROFILE)

# Zip target for easy distribution
zip: build
	@cd $(OUTPUT_DIR) && rm -f $(PROFILE).zip && zip -qr $(PROFILE).zip $(PROFILE)
	@echo "Packaged to: $(OUTPUT_DIR)/$(PROFILE).zip"

# Build all known profiles at once
all-profiles:
	@for p in $(basename $(notdir $(wildcard yuanshu-profiles/*.mk))); do \
		$(MAKE) PROFILE=$$p zip; \
	done
