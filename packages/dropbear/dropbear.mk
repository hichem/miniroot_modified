# options can be set in config.mk
DROPBEAR_SRC ?= 0.52
DROPBEAR_PATCH_DIR =
#DROPBEAR_BUILD_INSIDE = no

DROPBEAR_DEPS = zlib

# if DROPBEAR_SRC is a version number
ifeq ($(strip $(shell $(TOOLS_DIR)/is_src.sh '$(DROPBEAR_DIR)' '$(DROPBEAR_SRC)')),false)
override DROPBEAR_SRC := dropbear-$(strip $(DROPBEAR_SRC)).tar.bz2
DROPBEAR_URL = http://matt.ucc.asn.au/dropbear/releases/$(DROPBEAR_SRC)
endif

DROPBEAR_SRC_DIR = $(shell $(TOOLS_DIR)/get_src_dir.sh '$(DROPBEAR_DIR)' '$(DROPBEAR_SRC)')
DROPBEAR_BUILD_DIR = $(if $(DROPBEAR_BUILD_INSIDE), $(DROPBEAR_SRC_DIR), $(BUILD_DIR)/$(notdir $(DROPBEAR_SRC_DIR)))
DROPBEAR_BUILD_CONFIG = $(DROPBEAR_SRC_DIR)/options.h
DROPBEAR_BUILD_BIN = $(DROPBEAR_BUILD_DIR)/dropbearmulti
DROPBEAR_INSTALL_BIN = $(ROOT_BUILD_DIR)/sbin/$(notdir $(DROPBEAR_BUILD_BIN))
DROPBEAR_INSTALL_SERVER_ALIAS = $(ROOT_BUILD_DIR)/sbin/dropbear
DROPBEAR_INSTALL_CLIENT1_ALIAS = $(ROOT_BUILD_DIR)/bin/dbclient
DROPBEAR_INSTALL_CLIENT2_ALIAS = $(ROOT_BUILD_DIR)/bin/ssh
DROPBEAR_INSTALL_KEYGEN_ALIAS = $(ROOT_BUILD_DIR)/bin/dropbearkey

.PHONY: dropbear dropbear_init dropbear_clean
$(eval $(call PKG_INCLUDE_RULE, $(PKG_DROPBEAR_SERVER) $(PKG_DROPBEAR_CLIENT), dropbear))

dropbear: $(DROPBEAR_DEPS) $(DROPBEAR_INSTALL_BIN)

dropbear_init:
	@ echo '=== DROPBEAR ==='
	@ $(TOOLS_DIR)/init_src.sh '$(DROPBEAR_DIR)' '$(DROPBEAR_SRC)' '$(DROPBEAR_URL)' '$(DROPBEAR_PATCH_DIR)'

define DROPBEAR_DISABLE_FEATURE
sed -i 's,^\(#define.*$(1).*\),/*\1*/,' $(DROPBEAR_BUILD_CONFIG)
endef

$(DROPBEAR_BUILD_DIR)/Makefile:
	mkdir -p $(DROPBEAR_BUILD_DIR)
	( cd $(DROPBEAR_BUILD_DIR) && \
		$(SET_CROSS_PATH) $(SET_CROSS_CC) CFLAGS='$(CROSS_CFLAGS)' \
		$(abspath $(DROPBEAR_SRC_DIR))/configure \
			$(CONFIGURE_CROSS_HOST) \
			--srcdir='$(abspath $(DROPBEAR_SRC_DIR))' \
			--with-zlib='$(abspath $(ZLIB_BUILD_DIR))' \
			--disable-lastlog \
			--disable-utmp \
			--disable-utmp \
			--disable-wtmpx \
			--disable-wtmpx \
			--disable-loginfunc \
			--disable-pututline \
			--disable-pututxline \
	)
	$(call DROPBEAR_DISABLE_FEATURE, DROPBEAR_BLOWFISH)
	$(call DROPBEAR_DISABLE_FEATURE, DROPBEAR_TWOFISH)
	$(call DROPBEAR_DISABLE_FEATURE, DROPBEAR_MD5_HMAC)
	$(call DROPBEAR_DISABLE_FEATURE, ENABLE_.*FWD)
	$(call DROPBEAR_DISABLE_FEATURE, DO_MOTD)

$(DROPBEAR_BUILD_BIN): dropbear_init $(DROPBEAR_BUILD_DIR)/Makefile
	$(SET_CROSS_PATH) $(MAKE) -C $(DROPBEAR_BUILD_DIR) dropbearmulti \
	MULTI=1 PROGRAMS='$(strip \
		$(if $(call PKG_IS_SET, $(PKG_DROPBEAR_SERVER)), dropbear dropbearkey) \
		$(if $(call PKG_IS_SET, $(PKG_DROPBEAR_CLIENT)), dbclient) \
	)'

$(DROPBEAR_INSTALL_BIN): $(DROPBEAR_BUILD_BIN)
	install -D $(DROPBEAR_BUILD_BIN) $@
	$(CROSS_STRIP) $@
	mkdir -p $(ROOT_BUILD_DIR)/bin
	$(if $(call PKG_IS_SET, $(PKG_DROPBEAR_SERVER)), \
		ln -snf $(notdir $@) $(DROPBEAR_INSTALL_SERVER_ALIAS) && \
		ln -snf ../sbin/$(notdir $@) $(DROPBEAR_INSTALL_KEYGEN_ALIAS) \
	)
	$(if $(call PKG_IS_SET, $(PKG_DROPBEAR_CLIENT)), \
		ln -snf ../sbin/$(notdir $@) $(DROPBEAR_INSTALL_CLIENT1_ALIAS) && \
		ln -snf ../sbin/$(notdir $@) $(DROPBEAR_INSTALL_CLIENT2_ALIAS) \
	)

dropbear_clean:
	- $(if $(DROPBEAR_BUILD_INSIDE), \
		$(MAKE) -C $(DROPBEAR_BUILD_DIR) clean, \
		rm -rf $(DROPBEAR_BUILD_DIR) ) # make clean is broken in libtommath
	- rm -f $(DROPBEAR_INSTALL_BIN)
	- rm -f $(DROPBEAR_INSTALL_SERVER_ALIAS)
	- rm -f $(DROPBEAR_INSTALL_KEYGEN_ALIAS)
	- rm -f $(DROPBEAR_INSTALL_CLIENT1_ALIAS)
	- rm -f $(DROPBEAR_INSTALL_CLIENT2_ALIAS)