# if RT_EXTENSION_SRC is a version number
ifeq ($(strip $(shell $(TOOLS_DIR)/is_src.sh '$(LMBENCH_SRC)')),false)
override LMBENCH_SRC_SRC := $(LMBENCH_DIR)/lmbench-$(strip $(LMBENCH_SRC)).tar.bz2
LMBENCH_URL = http://garr.dl.sourceforge.net/sourceforge/lmbench/$(notdir $(LMBENCH_SRC))
endif

LMBENCH_SRC_DIR = $(shell $(TOOLS_DIR)/get_src_dir.sh '$(LMBENCH_DIR)' '$(LMBENCH_SRC)')

LMBENCH_MAKE = $(SET_PATH) $(MAKE) OS=$(notdir $(TOOLCHAIN_PATH)) \
			   CC=$(TOOLCHAIN_PREFIX)gcc LD=$(TOOLCHAIN_PREFIX)ld \
			   AR=$(TOOLCHAIN_PREFIX)ar AS=$(TOOLCHAIN_PREFIX)as \
			   BASE=$(abspath $(ROOT_BUILD_DIR))/usr/local

.PHONY:lmbench_init lmbench lmbench_shared_libs lmbench_build lmbench_clean
$(eval $(call PKG_INCLUDE_RULE, $(PKG_LMBENCH), lmbench))

lmbench_init:
	@ echo '=== LMBENCH ==='
	@ $(TOOLS_DIR)/init_src.sh '$(LMBENCH_DIR)' '$(LMBENCH_SRC)' '$(LMBENCH_URL)' '$(LMBENCH_PATCH)'

lmbench_build:lmbench_init	
	cd $(abspath $(LMBENCH_SRC_DIR)) && \
	$(LMBENCH_MAKE) build

lmbench_shared_libs: lmbench_build $(MKLIBS) $(SSTRIP) | $(ROOT_BUILD_LIB_DIR)
	$(SET_PATH) $(MKLIBS) \
		$(if $(TOOLCHAIN_PREFIX), --target $(TOOLCHAIN_PREFIX)) \
		-D -L $(TOOLCHAIN_PATH)/$(notdir $(TOOLCHAIN_PATH))/lib \
		--dest-dir $(ROOT_BUILD_LIB_DIR) --ldlib $(TOOLCHAIN_PATH)/$(notdir $(TOOLCHAIN_PATH))/lib/ld-linux.so.2 \
		`$(FIND_ROOT_BINS)`
	find $(ROOT_BUILD_LIB_DIR) -type f | xargs -r $(SSTRIP) 2>/dev/null || true

lmbench: lmbench_shared_libs
	cd $(abspath $(LMBENCH_SRC_DIR))/src && \
	$(LMBENCH_MAKE) install

lmbench_clean:
	rm -rf $(LMBENCH_SRC_DIR) 
