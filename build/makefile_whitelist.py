# Copyright (c) 2021 The Linux Foundation. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above
#       copyright notice, this list of conditions and the following
#       disclaimer in the documentation and/or other materials provided
#       with the distribution.
#     * Neither the name of The Linux Foundation nor the names of its
#       contributors may be used to endorse or promote products derived
#       from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT
# ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
# BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
# IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
SHELL_WHITELIST = {
    "vendor/qcom/proprietary/data-noship/qcril-data-utf/test/utf/Android.mk",
    "vendor/qcom/proprietary/wigig/ftm_flows/libwigig_ftm_flows/Android.mk",
    "vendor/qcom/proprietary/wigig/debug-tools/lib/FlashAcss/Android.mk",
    "vendor/qcom/proprietary/qvr-vndr/samples/apps/camera_test/Android.mk",
    "vendor/qcom/opensource/eva-kernel/Android.mk",
    "vendor/qcom/proprietary/qvr-vndr/tools/sensors_calibration/Android.mk",
    "vendor/qcom/proprietary/qvr-vndr/service/Android.mk",
    "vendor/qcom/proprietary/qvr-vndr/samples/plugins/eyetracking/Android.mk",
    "vendor/qcom/opensource/wlan/utils/sigma-dut/Android.mk",
    "vendor/qcom/proprietary/ts_firmware-noship/sm8150/Android.mk",
    "vendor/qcom/proprietary/wigig/sensing/sensingdaemon/Android.mk",
    "vendor/qcom/proprietary/qvr-vndr/samples/apps/imu_test/Android.mk",
    "vendor/qcom/proprietary/Innopath/FOTA/MobileUpdateClient/Android.mk",
    "vendor/qcom/proprietary/ts_firmware-noship/sm6125/Android.mk",
    "vendor/qcom/proprietary/ml/nnhal/qnn-gpu/QNN/GPU/OpPackage/Android.mk",
    "vendor/qcom/proprietary/wigig/debug-tools/lib/WlctPciAcss/Android.mk",
    "vendor/qcom/proprietary/qvr-vndr/tools/qvrdatalogger/Android.mk",
    "device/qcom/common/init/Android.mk",
    "vendor/qcom/proprietary/ml/nnhal/qnn-gpu/QNN/GPU/Backend/Android.mk",
    "vendor/qcom/proprietary/ts_firmware-noship/bengal/Android.mk",
    "vendor/qcom/proprietary/wigig/ftm_flows/ftm_flows_test/Android.mk",
    "vendor/qcom/proprietary/wlan/utils/halproxydaemon/Android.mk",
    "vendor/qcom/proprietary/qvr-vndr/common/Android.mk",
    "vendor/qcom/proprietary/wigig/debug-tools/lib/utils/Android.mk",
    "vendor/qcom/proprietary/ts_firmware/taro/Android.mk",
    "vendor/qcom/proprietary/qvr-vndr/services/2dframework/Android.mk",
    "vendor/qcom/proprietary/wigig-noship/location/libaoa/Android.mk",
    "vendor/qcom/proprietary/ac_policy-noship/Android.mk",
    "vendor/qcom/opensource/wlan/qcacld-3.0/Android.mk",
    "vendor/qcom/proprietary/securemsm-internal/isdbtmm/test/Android.mk",
    "vendor/qcom/proprietary/ts_firmware-noship/taro/Android.mk",
    "vendor/qcom/proprietary/ts_firmware-noship/lahaina/Android.mk",
    "vendor/qcom/proprietary/qvr-vndr/Android.mk",
    "vendor/qcom/proprietary/wigig/debug-tools/host_manager_11ad/Android.mk",
    "vendor/qcom/proprietary/platform-boost/platform_boost_hal/Android.mk",
    "vendor/qcom/proprietary/qvr-vndr/services/sxr/Android.mk",
    "vendor/qcom/proprietary/commonsys/openclwrapper/Android.mk",
    "vendor/qcom/proprietary/wlan/utils/qsh_wifi_test/Android.mk",
    "vendor/qcom/proprietary/wigig/debug-tools/shell_11ad/Android.mk",
    "vendor/qcom/proprietary/ts_firmware-noship/holi/Android.mk",
}

RM_WHITELIST = {
    "vendor/qcom/proprietary/biometrics/fingerprint/QFingerprintService/Android.mk",
    "vendor/qcom/proprietary/common/scripts/Android.mk",
    "vendor/qcom/proprietary/graphics/s-bins/Android.mk",
    "vendor/qcom/proprietary/biometrics/fingerprint/QFPCalibration/Android.mk",
}

LOCAL_COPY_HEADERS_WHITELIST = {
    "vendor/qcom/proprietary/common/config/Android.mk",
    "vendor/qcom/proprietary/peripheral-manager/libpmclient/Android.mk",
}

DATETIME_WHITELIST = {
    "vendor/qcom/proprietary/qvr-vndr/tools/AnchorTest/Android.mk",
    "vendor/qcom/proprietary/qvr-vndr/tools/qvrdatalogger/Android.mk",
    "vendor/qcom/proprietary/qvr-vndr/tools/qvrdatacapture/Android.mk",
}

TARGET_PRODUCT_WHITELIST = {
    "vendor/qcom/opensource/core-utils/build/AndroidBoardCommon.mk",
    "vendor/qcom/opensource/core-utils/build/QSSI_violators",
    "vendor/qcom/opensource/core-utils/build/build.sh",
    "vendor/qcom/opensource/core-utils/build/build_image_standalone.py",
}

RECURSIVE_WHITELIST = {
}

KERNEL_WHITELIST = {
}
