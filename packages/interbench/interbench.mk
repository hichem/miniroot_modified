# if RT_EXTENSION_SRC is a version number
ifeq ($(strip $(shell $(TOOLS_DIR)/is_src.sh '$(INTERBENCH_SRC)')),false)
override INTERBENCH_SRC_SRC := $(INTERBENCH_DIR)/interbench-$(strip $(INTERBENCH_SRC)).tar.bz2
INTERBENCH_URL = http://www.kernel.org/pub/linux/kernel/people/ck/apps/interbench/$(notdir $(INTERBENCH_SRC))
endif

INTERBENCH_SRC_DIR = $(shell $(TOOLS_DIR)/get_src_dir.sh '$(INTERBENCH_DIR)' '$(INTERBENCH_SRC)')

INTERBENCH_MAKE = $(SET_PATH) $(MAKE) CC=$(TOOLCHAIN_PREFIX)gcc LD=$(TOOLCHAIN_PREFIX)ld \
									AR=$(TOOLCHAIN_PREFIX)ar AS=$(TOOLCHAIN_PREFIX)as

SHARED_LIB_PATH = $(if $(TOOLCHAIN_PATH),$(strip $(TOOLCHAIN_PATH))/$(notdir $(TOOLCHAIN_PATH))/lib)

.PHONY:interbench_init interbench interbench_clean interbench_build
$(eval $(call PKG_INCLUDE_RULE, $(PKG_INTERBENCH), interbench))

interbench_init:
	@ echo '=== INTERBENCH ==='
	@ $(TOOLS_DIR)/init_src.sh '$(INTERBENCH_DIR)' '$(INTERBENCH_SRC)' '$(INTERBENCH_URL)' '$(INTERBENCH_PATCH)'

interbench_build:interbench_init	
	cd $(abspath $(INTERBENCH_SRC_DIR)) && \
	sed -i 's,^\(LFLAGS.*\),\1 -I $(TOOLCHAIN_PATH)/$(notdir $(TOOLCHAIN_PATH))/sys-root/usr/include,' Makefile && \
	sed -i 's,^LDFLAGS.*,LDFLAGS=-L $(TOOLCHAIN_PATH)/$(notdir $(TOOLCHAIN_PATH))/lib -lrt -lm,' Makefile && \
	$(INTERBENCH_MAKE) && \
	cp -r $(abspath $(INTERBENCH_SRC_DIR)) $(abspath $(ROOT_BUILD_DIR))/usr/local/

interbench: interbench_build $(MKLIBS) $(SSTRIP) | $(ROOT_BUILD_LIB_DIR)
	$(SET_PATH) $(MKLIBS) \
		$(if $(TOOLCHAIN_PREFIX), --target $(TOOLCHAIN_PREFIX)) \
		-D -L $(TOOLCHAIN_PATH)/$(notdir $(TOOLCHAIN_PATH))/lib \
		--dest-dir $(ROOT_BUILD_LIB_DIR) $(abspath $(INTERBENCH_SRC_DIR))/interbench && \
	cp $(TOOLCHAIN_PATH)/$(notdir $(TOOLCHAIN_PATH))/lib/libgcc_s.so.1 $(ROOT_BUILD_LIB_DIR)
	find $(ROOT_BUILD_LIB_DIR) -type f | xargs -r $(SSTRIP) 2>/dev/null || true

interbench_clean:
	rm -rf $(INTERBENCH_SRC_DIR) 
