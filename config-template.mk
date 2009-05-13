# Main targets
TARGETS = linux_all

# Directories
TARBALLS_DIR = /data/Automatisation/tarballs

# Host compilation

# Target compilation
TARGET_ARCH =
TOOLCHAIN_PATH =
TOOLCHAIN_PREFIX =
TARGET_LDFLAGS =
TARGET_CC = 'ccache $(TOOLCHAIN_PATH)/bin/$(TOOLCHAIN_PREFIX)gcc'

# Linux
LINUX_SRC =
LINUX_CONFIG =

# RT extensions
RT_EXTENSION =
RT_EXTENSION_SRC =
RT_LINUX_PATCH =
RT_ARCH_CONFIG =

# Root filesystem
ROOT_DEV_TABLE = $(ROOT_DIR)/default_dev_table
ROOT_SKEL_DIR = $(ROOT_DIR)/default_skel

# Busybox
BUSYBOX_SRC =

# Packages
PKG_DROPBEAR_SERVER = no
PKG_GNU_MAKE = yes
PKG_PERL = no
PKG_LMBENCH = no
PKG_INTERBENCH = yes
PKG_LCOV = yes

GNU_MAKE_SRC = $(TARBALLS_DIR)/make-3.81.tar.bz2
PERL_SRC = $(TARBALLS_DIR)/perl-5.10.0.tar.gz
LMBENCH_SRC = $(TARBALLS_DIR)/lmbench-2.5.tar.gz
INTERBENCH_SRC = $(TARBALLS_DIR)/interbench-0.30.tar.bz2
LCOV_SRC = $(TARBALLS_DIR)/lcov-1.7.tar.gz
