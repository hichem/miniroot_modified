PKG_BUILD_DIR = $(BUILD_DIR)

.PHONY: packages packages_clean
clean: packages_clean

define PKG_IS_SET
$(strip $(or \
	$(findstring y, $(1)), \
	$(findstring Y, $(1)), \
))
endef

define PKG_INCLUDE_RULE
ifneq ($(call PKG_IS_SET, $(1)),)
packages: $(2)
packages_clean: $(2)_clean
endif
endef

GNU_MAKE_DIR = $(PKG_DIR)/make
include $(GNU_MAKE_DIR)/make.mk

ZLIB_DIR = $(PKG_DIR)/zlib
include $(ZLIB_DIR)/zlib.mk

DROPBEAR_DIR = $(PKG_DIR)/dropbear
include $(DROPBEAR_DIR)/dropbear.mk

LIBROXML_DIR = $(PKG_DIR)/libroxml
include $(LIBROXML_DIR)/libroxml.mk

LMBENCH_DIR = $(PKG_DIR)/lmbench
include $(LMBENCH_DIR)/lmbench.mk

INTERBENCH_DIR = $(PKG_DIR)/interbench
include $(INTERBENCH_DIR)/interbench.mk

LTP_DIR = $(PKG_DIR)/ltp
include $(LTP_DIR)/ltp.mk
