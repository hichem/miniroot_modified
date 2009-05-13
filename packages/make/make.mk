# if GNU_MAKE_SRC is a version number
ifeq ($(strip $(shell $(TOOLS_DIR)/is_src.sh '$(GNU_MAKE_SRC)')),false)
override GNU_MAKE_SRC := $(GNU_MAKE_DIR)/GNU_MAKE-$(strip $(GNU_MAKE_SRC)).tar.bz2
GNU_MAKE_URL = http://ftp.gnu.org/pub/gnu/make/$(notdir $(GNU_MAKE_SRC))
endif

GNU_MAKE_SRC_DIR = $(shell $(TOOLS_DIR)/get_src_dir.sh '$(GNU_MAKE_DIR)' '$(GNU_MAKE_SRC)')
GNU_MAKE_BUILD_DIR = $(if $(GNU_MAKE_BUILD_INSIDE), $(GNU_MAKE_SRC_DIR), $(BUILD_DIR)/$(notdir $(GNU_MAKE_SRC_DIR)))

GNU_MAKE_MAKE = $(SET_PATH) $(MAKE) $(SET_ARCH) $(SET_CROSS_COMPILE) $(SET_CC) $(SET_LDFLAGS)
GNU_MAKE_CONFIGURE = $(abspath $(GNU_MAKE_SRC_DIR))/configure --prefix=$(abspath $(ROOT_BUILD_DIR))/usr/local

.PHONY: gnu_make gnu_make_configure gnu_make_init gnu_make_clean
$(eval $(call PKG_INCLUDE_RULE, $(PKG_GNU_MAKE), gnu_make))

gnu_make_init:
	@ echo '=== GNU MAKE ==='
	@ $(TOOLS_DIR)/init_src.sh '$(GNU_MAKE_DIR)' '$(GNU_MAKE_SRC)' '$(GNU_MAKE_URL)' '$(GNU_MAKE_PATCH)'

gnu_make:gnu_make_init gnu_make_configure
	cd $(abspath $(GNU_MAKE_BUILD_DIR)) && \
	$(GNU_MAKE_MAKE) && \
	$(GNU_MAKE_MAKE) install

gnu_make_configure:
	mkdir -p $(abspath $(GNU_MAKE_BUILD_DIR)) && \
	cd $(abspath $(GNU_MAKE_BUILD_DIR)) && \
	$(GNU_MAKE_CONFIGURE)

gnu_make_clean:
	rm -rf $(GNU_MAKE_BUILD_DIR)	
