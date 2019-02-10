#!/bin/bash
#
# Copyright (c) 2019, The Linux Foundation. All rights reserved.
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
# This script is mainly to compile QSSI targets. For other targets, usage
# of regular "make" is recommended.
#
# To run this script, do the following:
#
#  source build/envsetup.sh
#  lunch <target>-userdebug
#  ./vendor/qcom/opensource/core-utils/build/build.sh <make options>
#
# Note: For QSSI targets, this script cannot be used to compile individual images
#

# Check for qssi supported on this target or not
function check_return_value () {
retVal=$1
if [ $retVal -ne 0 ]; then
    echo "FAILED: build.sh: $2"
    exit $retVal
fi
}

QSSI_TARGETS_LIST=("sdm710" "sdm845" "msmnile" "talos")
QSSI_TARGET_FLAG=0

if [ "$TARGET_PRODUCT" == "qssi" ]; then
    echo "FAILED: build.sh: lunch option should not be set to qssi. Please set a target out of the following QSSI targets: ${QSSI_TARGETS_LIST[@]}"
    exit 1
fi

source build/envsetup.sh

for TARGET in "${QSSI_TARGETS_LIST[@]}"
do
    if [ "$TARGET_PRODUCT" == "$TARGET" ]; then
        QSSI_TARGET_FLAG=0 #TODO: Set this flag to 1 once all changes for lunch qssi are merged.
        break
    fi
done

# For non-QSSI targets
if [ $QSSI_TARGET_FLAG -eq 0 ]; then
    echo "build.sh: Using legacy build process for compilation ..."
    make "$@"
    check_return_value $? "make "$@""
else # For QSSI targets
    echo "build.sh: Building Android using build.sh for ${TARGET_PRODUCT} ..."
    TARGET="$TARGET_PRODUCT"

    lunch qssi-${TARGET_BUILD_VARIANT}
    check_return_value $? "lunch qssi-${TARGET_BUILD_VARIANT}"
    make droidcore_system "$@"
    check_return_value $? "make droidcore_system "$@""
    lunch ${TARGET}-$(TARGET_BUILD_VARIANT)
    check_return_value $? "lunch ${TARGET}-${TARGET_BUILD_VARIANT}"
    make droidcore_non_system "$@"
    check_return_value $? "make droidcore_non_system "$@""
fi
