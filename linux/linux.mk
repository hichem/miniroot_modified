# options can be set in config.mk
LINUX_SRC ?= 2.6.29.1 # <version | directory | tarball | VCS URL>
LINUX_PATCH_DIR ?= # [directory]
LINUX_CONFIG ?= # <file>
#LINUX_BUILD_INSIDE = no
#LINUX_VERBOSE = no

# if LINUX_SRC is a version number
ifeq ($(strip $(shell $(TOOLS_DIR)/is_src.sh '$(LINUX_SRC)')),false)
override LINUX_SRC := $(LINUX_DIR)/linux-$(strip $(LINUX_SRC)).tar.bz2
LINUX_URL = http://www.kernel.org/pub/linux/kernel/v2.6/$(notdir $(LINUX_SRC))
endif

LINUX_SRC_DIR = $(shell $(TOOLS_DIR)/get_src_dir.sh '$(LINUX_DIR)' '$(LINUX_SRC)')
LINUX_BUILD_DIR = $(if $(LINUX_BUILD_INSIDE), $(LINUX_SRC_DIR), $(BUILD_DIR)/$(notdir $(LINUX_SRC_DIR)))
LINUX_BUILD_CONFIG = $(LINUX_BUILD_DIR)/.config

LINUX_MAKE = $(SET_PATH) $(MAKE) -C $(LINUX_SRC_DIR) \
	$(SET_ARCH) $(SET_CROSS_COMPILE) $(SET_CC) \
	$(if $(LINUX_BUILD_INSIDE), , O='$(abspath $(LINUX_BUILD_DIR))') \
	$(if $(LINUX_VERBOSE), V=1)
LINUX_MAKE_OLDCONFIG = yes '' | $(LINUX_MAKE) oldconfig >/dev/null

LINUX_MODULES = $(shell grep '^CONFIG_MODULES=y' $(LINUX_BUILD_CONFIG) 2>/dev/null)
LINUX_INITRAMFS = $(shell grep '^CONFIG_INITRAMFS_SOURCE=' $(LINUX_BUILD_CONFIG) 2>/dev/null)
LINUX_GET_INITRAMFS = sed -n 's,^CONFIG_INITRAMFS_SOURCE="*\(.*\)"*,\1,p' $(LINUX_BUILD_CONFIG)
LINUX_SET_INITRAMFS = sed -i 's,^\(CONFIG_INITRAMFS_SOURCE=\).*,\1"$(abspath $(ROOT_CPIO))",' $(LINUX_BUILD_CONFIG)


.PHONY: linux linux_clean linux_init linux_init2 linux_init_src \
	linux_build_root linux_initramfs linux_no_initramfs \
	linux_modules linux_modules_install rtai_linux_src_config \
	rtai_linux_kernel_prepare linux_mrproper
clean: linux_clean

linux: linux_all

linux_init:
	@ echo '=== LINUX ==='
linux_init2:
	@ echo '=== LINUX === (part 2)'

linux_init_src:
	@ $(TOOLS_DIR)/init_src.sh '$(LINUX_DIR)' '$(LINUX_SRC)' '$(LINUX_URL)' '$(LINUX_PATCH_DIR)'
	@ $(MAKE) realtime_patch

$(LINUX_BUILD_CONFIG):
	@ echo '=== Configuring the Linux kernel ==='
	mkdir -p $(LINUX_BUILD_DIR)
	@ echo 'copy config to $(LINUX_BUILD_CONFIG)'
	@ if [ -f '$(strip $(LINUX_CONFIG))' ] ; then \
		cp $(LINUX_CONFIG) $(LINUX_BUILD_CONFIG) ; \
	else \
		cp $(LINUX_SRC_DIR)/arch/$(TARGET_ARCH)/configs/$(LINUX_CONFIG) $(LINUX_BUILD_CONFIG) ; \
	fi
	$(LINUX_MAKE_OLDCONFIG)
	sed -i 's,^CONFIG_NR_CPUS.*,CONFIG_NR_CPUS=2,' $(LINUX_BUILD_CONFIG)

linux_build_root: $(if $(LINUX_MODULES), linux_modules_install) realtime_install
	$(if $(LINUX_INITRAMFS), \
		$(MAKE) linux_initramfs, \
		$(MAKE) linux_no_initramfs \
	)

linux_mrproper:
	cd $(LINUX_SRC_DIR) && \
	$(MAKE) mrproper

linux_initramfs: image linux_init2 linux_mrproper
	@ if [ "`$(LINUX_GET_INITRAMFS)`" != '$(abspath $(ROOT_CPIO))' ] ; then \
		echo 'set CONFIG_INITRAMFS_SOURCE=$(ROOT_CPIO)' ; \
		$(LINUX_SET_INITRAMFS) && \
		$(LINUX_MAKE_OLDCONFIG) ; \
	fi

linux_no_initramfs:
	@ if [ "`$(LINUX_GET_INITRAMFS)`" != '' ] ; then \
		echo 'unset CONFIG_INITRAMFS_SOURCE' ; \
		$(LINUX_SET_INITRAMFS) && \
		$(LINUX_MAKE_OLDCONFIG) ; \
	fi

# wildcard rule
linux_%: linux_init linux_init_src  $(LINUX_BUILD_CONFIG)
	$(if $(or \
			$(filter all, $*), \
			$(filter vmlinux, $*), \
			$(filter %Image, $*), \
			$(filter %-pkg, $*), \
			$(filter %rpm, $*), \
			$(filter %install, $*) \
		), \
		$(MAKE) linux_build_root \
	)
	$(LINUX_MAKE) $*

linux_modules: linux_init_src $(LINUX_BUILD_CONFIG)
	@ echo '=== Building Linux modules ==='
	$(LINUX_MAKE) modules

linux_modules_install: linux_modules
	@ echo '=== Installing Linux modules ==='
	$(LINUX_MAKE) INSTALL_MOD_PATH=$(abspath $(ROOT_BUILD_DIR)) modules_install
	find $(ROOT_BUILD_LIB_DIR)/modules -name "*.ko" | xargs -r $(TARGET_STRIP)

linux_clean:
	- $(LINUX_MAKE) clean
	- rm -rf $(LINUX_SRC_DIR)
	- rm -rf $(LINUX_BUILD_DIR) 
