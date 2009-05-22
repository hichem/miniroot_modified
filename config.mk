# Main targets
TARGETS = linux_all

# Directories
TARBALLS_DIR = /data/Automatisation/tarballs

# Host compilation

# Target compilation
TARGET_ARCH = arm
TOOLCHAIN_PATH = /data/Automatisation/toolchains/arm-unknown-linux-gnu
TOOLCHAIN_PREFIX = arm-unknown-linux-gnu-
TARGET_LDFLAGS = -static 
TARGET_CC = 'ccache $(TOOLCHAIN_PATH)/bin/$(TOOLCHAIN_PREFIX)gcc'

# Linux
LINUX_SRC = /data/Automatisation/tarballs/linux-2.6.26.8.tar.gz
#LINUX_CONFIG = /data/Automatisation/arch/arm/configs/integrator_defconfig
LINUX_CONFIG = myarmconfig

# RT extensions
RT_EXTENSION = preempt-rt
RT_EXTENSION_SRC = /data/Automatisation/tarballs/patch-2.6.26.8-rt16
RT_LINUX_PATCH = /data/Automatisation/tarballs/patch-2.6.26.8-rt16
RT_ARCH_CONFIG =

# Root filesystem
ROOT_DEV_TABLE = $(ROOT_DIR)/default_dev_table
ROOT_SKEL_DIR = $(ROOT_DIR)/default_skel

# Busybox
BUSYBOX_SRC = /data/Automatisation/tarballs/busybox-1.13.2.tar.bz2

# Packages
PKG_DROPBEAR_SERVER = no
PKG_GNU_MAKE = no
PKG_PERL = no
PKG_LMBENCH = yes
PKG_INTERBENCH = yes
PKG_LTP = no

GNU_MAKE_SRC = $(TARBALLS_DIR)/make-3.81.tar.bz2
PERL_SRC = $(TARBALLS_DIR)/perl-5.10.0.tar.gz
LMBENCH_SRC = $(TARBALLS_DIR)/lmbench-2.5.tgz
INTERBENCH_SRC = $(TARBALLS_DIR)/interbench-0.30.tar.bz2
LTP_SRC = $(TARBALLS_DIR)/ltp-full-20090430.tgz
CROSSTOOL_SRC = $(TARBALLS_DIR)/crosstool-ng-1.3.2.tar.bz2
