# if RT_EXTENSION_SRC is a version number
ifeq ($(strip $(shell $(TOOLS_DIR)/is_src.sh '$(RT_EXTENSION_SRC)')),false)
override RT_EXTENSION_SRC := $(RTAI_DIR)/rtai-$(strip $(RT_EXTENSION_SRC)).tar.bz2
RTAI_URL = https://www.rtai.org/RTAI/$(notdir $(RT_EXTENSION_SRC))
endif

RTAI_SRC_DIR = $(shell $(TOOLS_DIR)/get_src_dir.sh '$(RTAI_DIR)' '$(RT_EXTENSION_SRC)')
RTAI_BUILD_DIR = $(BUILD_DIR)/$(notdir $(RTAI_SRC_DIR))

RTAI_KERNEL_PATCH = patch -p1  < $(abspath $(RTAI_SRC_DIR))/$(RT_LINUX_PATCH)
RTAI_MAKE = $(SET_PATH) $(MAKE) $(SET_ARCH) $(SET_CROSS_COMPILE) $(SET_CC)
RTAI_CONFIGURE = $(abspath $(RTAI_SRC_DIR))/configure --with-linux-dir=$(abspath $(LINUX_BUILD_DIR))

TARGET_LIB_DIRS += $(abspath $(ROOT_BUILD_DIR))/usr/realtime/lib


.PHONY: rtai_install rtai_configure rtai_kernel_patch rtai_init rtai_clean

clean: rtai_clean

rtai_init:
	@ echo '=== RTAI ==='
	@ $(TOOLS_DIR)/init_src.sh '$(RTAI_DIR)' '$(RT_EXTENSION_SRC)' '$(RTAI_URL)' '$(RTAI_PATCH_DIR)'

rtai_build: rtai_init rtai_configure
	@ echo '=== Building the RTAI user-space libraries ==='
	cd $(abspath $(RTAI_BUILD_DIR)) && \
	$(RTAI_MAKE)

rtai_install:rtai_build
	@ echo '=== Installing the RTAI user-space libraries ==='
	cd $(abspath $(RTAI_BUILD_DIR)) && \
	$(RTAI_MAKE) DESTDIR=$(abspath $(ROOT_BUILD_DIR)) install	

rtai_configure:
	@ echo '=== Configuring the RTAI for the user-space ==='
	mkdir $(RTAI_BUILD_DIR) && \
	cd $(RTAI_BUILD_DIR) && \
	$(RTAI_CONFIGURE)

rtai_kernel_patch: rtai_init
	@ echo '=== Applying the RTAI Patch to the kernel ==='
	cd $(LINUX_SRC_DIR) && \
	$(RTAI_KERNEL_PATCH)


rtai_clean:
	- rm -rf $(RTAI_BUILD_DIR) 
