ifeq ($(BOARD_USES_QCOM_HARDWARE),)
PRODUCT_SOONG_NAMESPACES += \
    vendor/qcom/opensource/core-utils/fwk-detect
endif
