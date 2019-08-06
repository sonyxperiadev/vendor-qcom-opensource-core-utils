# Copyright (c) 2018, The Linux Foundation. All rights reserved.

.PHONY: qssi_violators
qssi_violators: $(PRODUCT_OUT)/module-info.json
# Remove existing QSSI violators list (if present)
	if [ -s $$OUT/QSSI_violators.txt ]; then rm $$OUT/QSSI_violators.txt; fi
# Generate QSSI violators list
	vendor/qcom/opensource/core-utils/build/QSSI_violators

# KEYSTONE(I87be6f43b8940acf227798d99500af4a22551cbc,b/117238422)

# Remove unused targets below, and also mark phony targets as phony.

# module-info.json is not included when ONE_SHOT_MAKEFILE,
# hence disable qssi_violators for that as well.
# Also, QSSI enforcement is needed only for android-P(and above) new-launch devices.
ifndef ONE_SHOT_MAKEFILE
  ifdef PRODUCT_SHIPPING_API_LEVEL
    ifneq ($(call math_gt_or_eq,$(PRODUCT_SHIPPING_API_LEVEL),28),)
      droidcore: qssi_violators
      # droidcore_system appears to be obsolete.
      # droidcore_system: qssi_violators
      # droidcore_non_system should probably be obsolete, but it's still in use.
      .PHONY: droidcore_non_system
      droidcore_non_system: qssi_violators
    endif
  else # PRODUCT_SHIPPING_API_LEVEL is undefined
    droidcore: qssi_violators
    # droidcore_system appears to be obsolete.
    # droidcore_system: qssi_violators
    # droidcore_non_system should probably be obsolete, but it's still in use.
    .PHONY: droidcore_non_system
    droidcore_non_system: qssi_violators
  endif
endif
