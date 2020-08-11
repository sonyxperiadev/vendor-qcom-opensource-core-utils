# TODO: Switch to TARGET_BOARD_PLATFORM when taro goes live
ifeq ($(filter $(TARGET_PRODUCT), taro),$(TARGET_PRODUCT))
IMAGE_GENERATION_TOOLS := image_generation_tool

PRODUCT_HOST_PACKAGES += $(IMAGE_GENERATION_TOOLS)
endif
