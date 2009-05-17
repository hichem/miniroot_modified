# RTAI
RTAI_DIR = $(REALTIME_DIR)/rtai

# Xenomai
XENOMAI_DIR = $(REALTIME_DIR)/xenomai

# Preempt-RT
PREEMPT_RT_DIR = $(REALTIME_DIR)/preempt_rt

define RT_PA

endef

ifdef RT_EXTENSION
ifeq ($(strip $(RT_EXTENSION)),xenomai)
	include $(XENOMAI_DIR)/xenomai.mk
	XENOMAI = yes
else ifeq ($(strip $(RT_EXTENSION)),rtai)
	include $(RTAI_DIR)/rtai.mk
	RTAI = yes
else ifeq ($(strip $(RT_EXTENSION)),preempt-rt)
	include $(PREEMPT_RT_DIR)/preempt_rt.mk
	PREEMPT_RT = yes
endif
endif

.PHONY:realtime_install realtime_patch apply_rt_patch patch_clean

clean: patch_clean

realtime_install: $(if $(XENOMAI), xenomai_install) $(if $(RTAI), rtai_install)

realtime_patch:
	@ if [ -f "$(REALTIME_DIR)/patched" ]; \
	then \
	echo "Kernel already patched"; \
	else \
	$(MAKE) apply_rt_patch && \
	touch "$(REALTIME_DIR)/patched"; \
	fi

apply_rt_patch: $(if $(XENOMAI), xenomai_kernel_patch) \
				$(if $(RTAI), rtai_kernel_patch) \
				$(if $(PREEMPT_RT), preempt_rt_kernel_patch)

patch_clean:
	- rm -f $(REALTIME_DIR)/patched
