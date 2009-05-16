# if RT_EXTENSION_SRC is a version number
ifeq ($(strip $(shell $(TOOLS_DIR)/is_src.sh '$(RT_EXTENSION_SRC)')),false)
override RT_EXTENSION_SRC := $(XENOMAI_DIR)/xenomai-$(strip $(RT_EXTENSION_SRC)).tar.bz2
XENOMAI_URL = http://download.gna.org/xenomai/stable/$(notdir $(RT_EXTENSION_SRC))
endif

XENOMAI_SRC_DIR = $(shell $(TOOLS_DIR)/get_src_dir.sh '$(XENOMAI_DIR)' '$(RT_EXTENSION_SRC)')
XENOMAI_BUILD_DIR = $(BUILD_DIR)/$(notdir $(XENOMAI_SRC_DIR))

XENOMAI_MAKE = $(SET_PATH) $(MAKE) -C $(XENOMAI_SRC_DIR) \
	$(SET_ARCH) $(SET_CROSS_COMPILE) $(SET_CC) \
	O='$(abspath $(XENOMAI_BUILD_DIR))'

ifeq ($(TARGET_ARCH), x86)
	XENO_ARCH = i386
else ifeq ($(TARGET_ARCH), powerpc)
	XENO_ARCH = ppc
else
	XENO_ARCH = $(TARGET_ARCH)
endif

XENOMAI_KERNEL_PATCH = $(abspath $(XENOMAI_SRC_DIR))/scripts/prepare-kernel.sh --arch=$(XENO_ARCH) \
							--adeos=$(XENOMAI_SRC_DIR)/$(RT_LINUX_PATCH) \
							--linux=$(LINUX_SRC_DIR)
XENOMAI_CONFIGURE = $(SET_PATH) $(abspath $(XENOMAI_SRC_DIR))/configure CC=$(TOOLCHAIN_PREFIX)gcc CXX=$(TOOLCHAIN_PREFIX)g++ \
								AR=$(TOOLCHAIN_PREFIX)ar LD=$(TOOLCHAIN_PREFIX)ld --host=arm-unknown-linux-gnu --enable-arm-mach=generic

TARGET_LIB_DIRS += $(abspath $(ROOT_BUILD_DIR))/usr/xenomai/lib

#ifeq ($(CROSS_ARCH),x86)
#	XENOMAI_KERNEL_PATCH = $(abspath $(XENOMAI_SRC_DIR))/scripts/prepare-kernel.sh --arch=i386 \
#							--adeos=$(XENOMAI_SRC_DIR)/ksrc/arch/x86/patches/adeos-ipipe-2.6.24-x86-2.0-07.patch \
#							--linux=$(LINUX_SRC_DIR)
#	XENOMAI_CONFIGURE = $(abspath $(XENOMAI_SRC_DIR))/configure --enable-x86-sep
#else ifeq ($(CROSS_ARCH),x86_64)
#	XENOMAI_KERNEL_PATCH = $(abspath $(XENOMAI_SRC_DIR))/scripts/prepare-kernel.sh --arch=x86_64 \
#							--adeos=$(XENOMAI_SRC_DIR)/ksrc/arch/x86/patches/adeos-ipipe-2.6.23-x86_64-X.Y-ZZ.patch \
#							--linux=$(LINUX_SRC_DIR)
#	XENOMAI_CONFIGURE = $(abspath $(XENOMAI_SRC_DIR))/configure
#else ifeq ($(CROSS_ARCH),powerpc)
#	XENOMAI_KERNEL_PATCH = $(abspath $(XENOMAI_SRC_DIR))/scripts/prepare-kernel.sh --arch=ia64 \
#							--adeos=$(XENOMAI_SRC_DIR)/ksrc/arch/powerpc/patches/adeos-ipipe-2.6.14-ppc-1.5-*.patch \
#							--linux=$(LINUX_SRC_DIR)
#	XENOMAI_CONFIGURE = $(abspath $(XENOMAI_SRC_DIR))/configure --build=i686-pc-linux-gnu --host=ppc-unknown-linux-gnu \
#							CC=ppc_4xx-gcc CXX=ppc_4xx-g++ LD=ppc_4xx-ld
#else ifeq ($(CROSS_ARCH),ia64)
#	XENOMAI_KERNEL_PATCH = $(abspath $(XENOMAI_SRC_DIR))/scripts/prepare-kernel.sh --arch=ppc \
#							--adeos=$(XENOMAI_SRC_DIR)/ksrc/arch/ia64/patches/adeos-ipipe-2.6.15-ia64-X.Y-ZZ.patch \
#							--linux=$(LINUX_SRC_DIR)
#	XENOMAI_CONFIGURE = $(abspath $(XENOMAI_SRC_DIR))/configure --build=i686-pc-linux-gnu --host=ia64-unknown-linux-gnu \
#							CC=ia64_4xx-gcc CXX=ia64_4xx-g++ LD=ia64_4xx-ld
#else ifeq ($(CROSS_ARCH),arm)
#	XENOMAI_KERNEL_PATCH = $(abspath $(XENOMAI_SRC_DIR))/scripts/prepare-kernel.sh --arch=arm \
#							--adeos=$(XENOMAI_SRC_DIR)/ksrc/arch/arm/patches/adeos-ipipe-2.6.26-arm-1.9-03.patch \
#							--linux=$(LINUX_SRC_DIR)
#	XENOMAI_CONFIGURE = $(SET_PATH) $(abspath $(XENOMAI_SRC_DIR))/configure --host=arm-unknown-linux-gnu --enable-arm-mach=at91rm9200 \
#						--enable-arm-tsc CC=$(CROSS_PREFIX)gcc CXX=$(CROSS_PREFIX)gcc AR=$(CROSS_PREFIX)ar LD=$(CROSS_PREFIX)ld 
#endif


.PHONY: xenomai_install xenomai_configure xenomai_kernel_patch xenomai_init xenomai_clean

clean: xenomai_clean

xenomai_init:
	@ echo '=== Xenomai ==='
	@ $(TOOLS_DIR)/init_src.sh '$(XENOMAI_DIR)' '$(RT_EXTENSION_SRC)' '$(XENOMAI_URL)' '$(XENOMAI_PATCH_DIR)'

xenomai_install: xenomai_init xenomai_configure
	@ echo '=== Installing the Xenomai user-space libraries ==='
	cd $(XENOMAI_BUILD_DIR) && \
	$(SET_PATH) fakeroot $(MAKE) $(SET_ARCH) $(SET_CROSS_COMPILE) $(SET_CC) \
		DESTDIR=$(abspath $(ROOT_BUILD_DIR)) install

xenomai_configure:
	@ echo '=== Configuring the Xenomai for the user-space ==='
	mkdir -p $(XENOMAI_BUILD_DIR) && \
	cd $(XENOMAI_BUILD_DIR) && \
	$(XENOMAI_CONFIGURE)

xenomai_kernel_patch: xenomai_init
	@ echo '=== Applying the Xenomai Patch to the kernel ==='
	$(XENOMAI_KERNEL_PATCH)

xenomai_clean:
	- rm -rf $(XENOMAI_BUILD_DIR)
	- rm -rf $(XENOMAI_SRC_DIR)
