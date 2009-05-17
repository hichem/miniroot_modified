PREEMPT_RT_PATCH = patch -d $(abspath $(LINUX_SRC_DIR)) -p1 < $(RT_LINUX_PATCH)

.PHONY:preempt_rt_kernel_patch
#.IGNORE:preempt_rt_kernel_patch

preempt_rt_kernel_patch:
	@ echo '=== Applying the PREEMPT-RT Patch to the kernel ==='
	$(PREEMPT_RT_PATCH) 
