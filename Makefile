all:

# Overwrite default configuration with user parameters
include config.mk

# Main targets
.PHONY: all clean
TARGETS ?= linux image
all: $(TARGETS)

# Host compilation
SET_HOST_CC = $(if $(HOST_CC), CC=$(HOST_CC))

# Target compilation
TARGET_CPPFLAGS ?=
TARGET_CFLAGS ?= -Os
TARGET_CXXFLAGS ?= -Os
TARGET_LDFLAGS ?= -static
SET_ARCH = $(if $(TARGET_ARCH), ARCH=$(TARGET_ARCH))
SET_CROSS_COMPILE = $(if $(TOOLCHAIN_PREFIX), CROSS_COMPILE=$(TOOLCHAIN_PREFIX))
SET_PATH = $(if $(TOOLCHAIN_PATH), PATH="$$PATH:$(abspath $(TOOLCHAIN_PATH))/bin")
SET_CC = $(if $(TARGET_CC), CC=$(TARGET_CC))
SET_CXX = $(if $(TARGET_CXX), CXX=$(TARGET_CXX))
SET_CPPFLAGS = $(if $(TARGET_CPPFLAGS), CPPFLAGS='$(TARGET_CPPFLAGS)')
SET_CFLAGS = $(if $(TARGET_CFLAGS), CFLAGS='$(TARGET_CFLAGS)')
SET_CXXFLAGS = $(if $(TARGET_CXXFLAGS), CXXFLAGS='$(TARGET_CXXFLAGS)')
SET_LDFLAGS = $(if $(TARGET_LDFLAGS), LDFLAGS='$(TARGET_LDFLAGS)')
TARGET_STATIC = $(findstring -static, $(TARGET_LDFLAGS))
TARGET_LIB_DIRS += $(if $(TOOLCHAIN_PATH), $(strip $(TOOLCHAIN_PATH))/lib)
TARGET_LIB_DIRS += $(if $(TOOLCHAIN_PATH), $(strip $(TOOLCHAIN_PATH))/$(notdir $(TOOLCHAIN_PATH))/lib)
CONFIGURE_HOST = $(if $(TOOLCHAIN_PREFIX), --host=$(strip $(TOOLCHAIN_PREFIX:-=)))
TOOLCHAIN_PATH_PREFIX = $(if $(TOOLCHAIN_PATH), $(strip $(TOOLCHAIN_PATH))/bin/$(TOOLCHAIN_PREFIX))
TARGET_STRIP = $(TOOLCHAIN_PATH_PREFIX)strip -s

# Build outside of the sources
BUILD_DIR ?= build

# Build tools
TOOLS_DIR = tools
include $(TOOLS_DIR)/tools.mk

# Build toolchain
TOOLCHAIN_DIR = toolchain
include $(TOOLCHAIN_DIR)/toolchain.mk

# Realtime Linux
REALTIME_DIR = realtime
include $(REALTIME_DIR)/realtime.mk

# Linux
LINUX_DIR = linux
include $(LINUX_DIR)/linux.mk

# Image
IMAGE_DIR = image
include $(IMAGE_DIR)/image.mk

# Root filesystem
ROOT_DIR = root
include $(ROOT_DIR)/root.mk

# Busybox
BUSYBOX_DIR = busybox
include $(BUSYBOX_DIR)/busybox.mk

# Packages
PKG_DIR = packages
include $(PKG_DIR)/packages.mk

# Add user-defined rules which can use variables previously defined
ifdef EXTRA_RULES
include $(EXTRA_RULES)
endif
