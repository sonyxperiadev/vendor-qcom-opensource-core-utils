# Copyright (c) 2018, The Linux Foundation. All rights reserved.

qssi_violators: $(PRODUCT_OUT)/module-info.json
# Remove existing QSSI violators list (if present)
	if [ -s $$OUT/QSSI_violators.txt ]; then rm $$OUT/QSSI_violators.txt; fi
# Generate QSSI violators list
	vendor/qcom/opensource/core-utils/build/QSSI_violators

# module-info.json is not included when ONE_SHOT_MAKEFILE,
# hence disable qssi_violators for that as well.
ifndef ONE_SHOT_MAKEFILE
files: qssi_violators
endif
