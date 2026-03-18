ROOT_DIR := $(shell pwd)
SRC_DIR := $(ROOT_DIR)/yuanshu-config
SKINS_DIR := $(ROOT_DIR)/yuanshu-skin
OUTPUT_DIR := $(ROOT_DIR)/yuanshu-output
YUANSHU_OUT := $(OUTPUT_DIR)/yuanshu
CUSTOMER_OUT := $(OUTPUT_DIR)/customer-shuffle17

# Find all skin directories
SKIN_DIRS := $(wildcard $(SKINS_DIR)/*)
SKIN_NAMES := $(notdir $(SKIN_DIRS))
SKIN_CSKINS := $(patsubst %,$(YUANSHU_OUT)/%.cskin,$(SKIN_NAMES))
CUSTOMER_SKIN := $(CUSTOMER_OUT)/shuffle17.cskin

.PHONY: all clean build-yuanshu build-customer-pack copy-yuanshu-files

all: build-yuanshu build-customer-pack

clean:
	rm -rf $(OUTPUT_DIR)

# --- Yuanshu (Personal) Build ---

build-yuanshu: $(YUANSHU_OUT)/cangjie5.dict.yaml copy-yuanshu-files $(SKIN_CSKINS)

copy-yuanshu-files:
	@mkdir -p $(YUANSHU_OUT)
	cp $(ROOT_DIR)/cangjie6.dict.yaml $(YUANSHU_OUT)/
	cp $(ROOT_DIR)/cangjie6.extended.dict.yaml $(YUANSHU_OUT)/
	cp $(ROOT_DIR)/cangjie6.schema.yaml $(YUANSHU_OUT)/
	cp $(ROOT_DIR)/cangjie5.schema.yaml $(YUANSHU_OUT)/
	cp $(ROOT_DIR)/flypy.schema.yaml $(YUANSHU_OUT)/
	cp $(ROOT_DIR)/flypy.yaml $(YUANSHU_OUT)/
	cp $(ROOT_DIR)/jyut6ping3.schema.yaml $(YUANSHU_OUT)/
	cp $(ROOT_DIR)/jyut6ping3.dict.yaml $(YUANSHU_OUT)/
	cp -R $(ROOT_DIR)/jyut6ping3_dicts $(YUANSHU_OUT)/
	cp $(ROOT_DIR)/luna_pinyin.dict.yaml $(YUANSHU_OUT)/
	cp $(ROOT_DIR)/symbols_cantonese.yaml $(YUANSHU_OUT)/
	cp $(ROOT_DIR)/terra_pinyin.dict.yaml $(YUANSHU_OUT)/
	cp $(ROOT_DIR)/zhuyin.yaml $(YUANSHU_OUT)/
	cp $(SRC_DIR)/flypy_ice.schema.yaml $(YUANSHU_OUT)/
	cp $(SRC_DIR)/shuffle17_ice.schema.yaml $(YUANSHU_OUT)/
	cp $(SRC_DIR)/rime_ice.dict.yaml $(YUANSHU_OUT)/
	cp -R $(SRC_DIR)/rime_ice_dicts $(YUANSHU_OUT)/
	cp $(SRC_DIR)/cangjie5.custom.yaml $(YUANSHU_OUT)/
	cp $(SRC_DIR)/cangjie6.custom.yaml $(YUANSHU_OUT)/
	cp $(SRC_DIR)/flypy.custom.yaml $(YUANSHU_OUT)/
	cp $(SRC_DIR)/flypy_ice.custom.yaml $(YUANSHU_OUT)/
	cp $(SRC_DIR)/jyut6ping3.custom.yaml $(YUANSHU_OUT)/
	cp $(SRC_DIR)/shuffle17_ice.custom.yaml $(YUANSHU_OUT)/

$(YUANSHU_OUT)/cangjie5.dict.yaml: $(ROOT_DIR)/cangjie5.dict.yaml
	@mkdir -p $(YUANSHU_OUT)
	awk '\
		/^use_preset_vocabulary:/ { print "use_preset_vocabulary: true"; seen_use=1; next } \
		/^max_phrase_length:/ { print "max_phrase_length: 7"; seen_max=1; next } \
		/^min_phrase_weight:/ { if (!seen_use) print "use_preset_vocabulary: true"; if (!seen_max) print "max_phrase_length: 7" } \
		{ print } \
	' $< > $@

# Skin compilation rule
$(YUANSHU_OUT)/%.cskin: $(SKINS_DIR)/% $(SKINS_DIR)/%/jsonnet/main.jsonnet
	@echo "Building skin: $*"
	@mkdir -p $(OUTPUT_DIR)/tmp/build-$*/dark $(OUTPUT_DIR)/tmp/build-$*/light $(OUTPUT_DIR)/tmp/$* $(YUANSHU_OUT)
	cp -R $(SKINS_DIR)/$*/* $(OUTPUT_DIR)/tmp/$*/
	jsonnet -m $(OUTPUT_DIR)/tmp/build-$* $(SKINS_DIR)/$*/jsonnet/main.jsonnet >/dev/null
	rm -rf $(OUTPUT_DIR)/tmp/$*/dark $(OUTPUT_DIR)/tmp/$*/light
	cp -R $(OUTPUT_DIR)/tmp/build-$*/dark $(OUTPUT_DIR)/tmp/$*/
	cp -R $(OUTPUT_DIR)/tmp/build-$*/light $(OUTPUT_DIR)/tmp/$*/
	@if [ -f "$(OUTPUT_DIR)/tmp/build-$*/config.yaml" ]; then \
		cp $(OUTPUT_DIR)/tmp/build-$*/config.yaml $(OUTPUT_DIR)/tmp/$*/config.yaml; \
	fi
	cd $(OUTPUT_DIR)/tmp && zip -qr $@ $*
	@rm -rf $(OUTPUT_DIR)/tmp

# --- Customer Build ---

build-customer-pack: $(CUSTOMER_SKIN)
	@mkdir -p $(CUSTOMER_OUT)
	cp $(SRC_DIR)/shuffle17_ice.schema.yaml $(CUSTOMER_OUT)/
	cp $(SRC_DIR)/shuffle17_ice.custom.yaml $(CUSTOMER_OUT)/
	cp $(SRC_DIR)/rime_ice.dict.yaml $(CUSTOMER_OUT)/
	cp -R $(SRC_DIR)/rime_ice_dicts $(CUSTOMER_OUT)/
	cp $(ROOT_DIR)/cangjie6.schema.yaml $(CUSTOMER_OUT)/
	cp $(ROOT_DIR)/cangjie6.dict.yaml $(CUSTOMER_OUT)/
	cp $(ROOT_DIR)/cangjie6.extended.dict.yaml $(CUSTOMER_OUT)/
	@echo "patch:" > $(CUSTOMER_OUT)/default.custom.yaml
	@echo "  schema_list:" >> $(CUSTOMER_OUT)/default.custom.yaml
	@echo "    - schema: shuffle17_ice" >> $(CUSTOMER_OUT)/default.custom.yaml
	cd $(OUTPUT_DIR) && rm -f customer-shuffle17.zip && zip -qr customer-shuffle17.zip customer-shuffle17
	@echo "Customer pack created at: $(OUTPUT_DIR)/customer-shuffle17.zip"

$(CUSTOMER_OUT)/shuffle17.cskin: $(SKINS_DIR)/shuffle17 $(SKINS_DIR)/shuffle17/jsonnet/main.jsonnet
	@echo "Building skin for customer: shuffle17"
	@mkdir -p $(OUTPUT_DIR)/tmp-customer/build-shuffle17/dark $(OUTPUT_DIR)/tmp-customer/build-shuffle17/light $(OUTPUT_DIR)/tmp-customer/shuffle17 $(CUSTOMER_OUT)
	cp -R $(SKINS_DIR)/shuffle17/* $(OUTPUT_DIR)/tmp-customer/shuffle17/
	jsonnet -m $(OUTPUT_DIR)/tmp-customer/build-shuffle17 $(SKINS_DIR)/shuffle17/jsonnet/main.jsonnet >/dev/null
	rm -rf $(OUTPUT_DIR)/tmp-customer/shuffle17/dark $(OUTPUT_DIR)/tmp-customer/shuffle17/light
	cp -R $(OUTPUT_DIR)/tmp-customer/build-shuffle17/dark $(OUTPUT_DIR)/tmp-customer/shuffle17/
	cp -R $(OUTPUT_DIR)/tmp-customer/build-shuffle17/light $(OUTPUT_DIR)/tmp-customer/shuffle17/
	@if [ -f "$(OUTPUT_DIR)/tmp-customer/build-shuffle17/config.yaml" ]; then \
		cp $(OUTPUT_DIR)/tmp-customer/build-shuffle17/config.yaml $(OUTPUT_DIR)/tmp-customer/shuffle17/config.yaml; \
	fi
	cd $(OUTPUT_DIR)/tmp-customer && zip -qr $@ shuffle17
	@rm -rf $(OUTPUT_DIR)/tmp-customer
