LOCAL_PATH:= $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE        := qti_skip_mount.cfg
LOCAL_MODULE_STEM   := skip_mount.cfg
LOCAL_MODULE_TAGS   := optional
LOCAL_MODULE_CLASS  := ETC
LOCAL_SRC_FILES     := $(LOCAL_MODULE)
LOCAL_SYSTEM_EXT_MODULE := true
LOCAL_MODULE_RELATIVE_PATH := init/config
include $(BUILD_PREBUILT)