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

###########################
# Build.sh versioning:
###########################
# build.sh supports '--version' option, returns the version number.
# Version number is based on the features/commands supported by it.
# The file - './vendor/qcom/opensource/core-utils/build/build.sh.versioned' indicates that build.sh
# supports versioning. So, it's required to first check for this file's existence before
# calling with '--version', since this versioning support didn't exist from the beginning of this script.
#
# Version 0:
#     Supports just the basic make commands (passes on all args like -j32 to the make command).
# Version 1:
#     Supports dist command as well - needed for target-files/ota generation.
#     Usage: ./build.sh dist -j32
#     This triggers make dist for qssi and target lunch, generates target-files, merges them
#     and triggers ota generation.
#
BUILD_SH_VERSION=1
###########################

QSSI_TARGETS_LIST=("sdm710" "sdm845" "msmnile" "sm6150" "kona" "atoll")
QSSI_TARGET_FLAG=0

# Default A/B configuration flag for all QSSI targets (not used for legacy targets).
ENABLE_AB=true
ARGS="$@"
QSSI_ARGS="$ARGS ENABLE_AB=$ENABLE_AB"

#TODO: Remove BUILD_KONA_WITH_QSSI flag once lunch qssi changes on Kona merge.
if [ "$TARGET_PRODUCT" == "kona" ]; then
    QSSI_ARGS="$QSSI_ARGS BUILD_KONA_WITH_QSSI=true"
fi

# OTA/Dist related variables
DIST_COMMAND="dist"
DIST_ENABLED=false
QSSI_ARGS_WITHOUT_DIST=""
DIST_DIR="out/dist"
MERGED_TARGET_FILES="$DIST_DIR/merged-qssi_${TARGET_PRODUCT}-target_files.zip"
MERGED_OTA_ZIP="$DIST_DIR/merged-qssi_${TARGET_PRODUCT}-ota.zip"
DIST_ENABLED_TARGET_LIST=("sdm710" "sdm845" "msmnile" "sm6150")

for ARG in $QSSI_ARGS
do
    if [ "$ARG" == "--version" ]; then
        return "$BUILD_SH_VERSION"
        # Above return will work only if someone source'ed this script (which is expected, need to source the script).
        # Add extra exit 0 to ensure script doesn't proceed further (if someone didn't use source but passed --version)
        exit 0
    elif [ "$ARG" == "$DIST_COMMAND" ]; then
        DIST_ENABLED=true
    else
        QSSI_ARGS_WITHOUT_DIST="$QSSI_ARGS_WITHOUT_DIST $ARG"
    fi
done

# Check if dist is supported on this target (yet) or not, and override DIST_ENABLED flag.
IS_DIST_ENABLED_TARGET=false
for TARGET in "${DIST_ENABLED_TARGET_LIST[@]}"
do
    if [ "$TARGET_PRODUCT" == "$TARGET" ]; then
        IS_DIST_ENABLED_TARGET=true
        break
    fi
done

function log() {
    echo "============================================"
    echo "[build.sh]: $@"
    echo "============================================"
}

# Disable dist if it's not supported (yet).
if [ "$IS_DIST_ENABLED_TARGET" = false ] && [ "$DIST_ENABLED" = true ]; then
    QSSI_ARGS="$QSSI_ARGS_WITHOUT_DIST"
    DIST_ENABLED=false
    log "Dist not (yet) enabled for $TARGET_PRODUCT"
fi

function check_return_value () {
    retVal=$1
    command=$2
    if [ $retVal -ne 0 ]; then
        log "FAILED: $command"
        exit $retVal
    fi
}

function command () {
    command=$@
    log "Command: \"$command\""
    time $command
    retVal=$?
    check_return_value $retVal "$command"
}

function check_if_file_exists () {
    if [[ ! -f "$1" ]]; then
        log "Could not find the file: \"$1\", aborting.."
        exit 1
    fi
}

function generate_ota_zip () {
    log "Processing dist/ota commands:"

    SYSTEM_TARGET_FILES="$(find $DIST_DIR -name "qssi*-target_files-*.zip" -print)"
    log "SYSTEM_TARGET_FILES=$SYSTEM_TARGET_FILES"
    check_if_file_exists "$SYSTEM_TARGET_FILES"

    OTHER_TARGET_FILES="$(find $DIST_DIR -name "${TARGET_PRODUCT}*-target_files-*.zip" -print)"
    log "OTHER_TARGET_FILES=$OTHER_TARGET_FILES"
    check_if_file_exists "$OTHER_TARGET_FILES"

    log "MERGED_TARGET_FILES=$MERGED_TARGET_FILES"

    check_if_file_exists "$DIST_DIR/merge_config_system_misc_info_keys"
    check_if_file_exists "$DIST_DIR/merge_config_system_item_list"
    check_if_file_exists "$DIST_DIR/merge_config_other_item_list"

    MERGE_TARGET_FILES_COMMAND="./build/tools/releasetools/merge_target_files.py \
        --system-target-files $SYSTEM_TARGET_FILES \
        --other-target-files $OTHER_TARGET_FILES \
        --output-target-files $MERGED_TARGET_FILES \
        --system-misc-info-keys $DIST_DIR/merge_config_system_misc_info_keys \
        --system-item-list $DIST_DIR/merge_config_system_item_list \
        --other-item-list $DIST_DIR/merge_config_other_item_list"

    if [ "$ENABLE_AB" = false ]; then
        MERGE_TARGET_FILES_COMMAND="$MERGE_TARGET_FILES_COMMAND --rebuild_recovery"
    fi

    command "$MERGE_TARGET_FILES_COMMAND"
    log "MERGED_OTA_ZIP=$MERGED_OTA_ZIP"
    command "./build/tools/releasetools/ota_from_target_files.py -v $MERGED_TARGET_FILES $MERGED_OTA_ZIP"
}

if [ "$TARGET_PRODUCT" == "qssi" ]; then
    log "FAILED: lunch option should not be set to qssi. Please set a target out of the following QSSI targets: ${QSSI_TARGETS_LIST[@]}"
    exit 1
fi

# Check if qssi is supported on this target or not.
for TARGET in "${QSSI_TARGETS_LIST[@]}"
do
    if [ "$TARGET_PRODUCT" == "$TARGET" ]; then
        QSSI_TARGET_FLAG=1
        break
    fi
done

# For non-QSSI targets
if [ $QSSI_TARGET_FLAG -eq 0 ]; then
    log "${TARGET_PRODUCT} is not a QSSI target. Using legacy build process for compilation..."
    command "source build/envsetup.sh"
    command "make $ARGS"
else # For QSSI targets
    log "Building Android using build.sh for ${TARGET_PRODUCT}..."
    log "QSSI_ARGS=\"$QSSI_ARGS\""
    log "DIST_ENABLED=$DIST_ENABLED, ENABLE_AB=$ENABLE_AB"

    TARGET="$TARGET_PRODUCT"

    command "source build/envsetup.sh"
    command "lunch qssi-${TARGET_BUILD_VARIANT}"
    command "$QTI_BUILDTOOLS_DIR/build/kheaders-dep-scanner.sh"
    command "make $QSSI_ARGS"
    command "lunch ${TARGET}-${TARGET_BUILD_VARIANT}"
    command "make $QSSI_ARGS"

    # Copy Qssi system.img to target folder so that all images can be picked up from one folder
    command "cp out/target/product/qssi/system.img $OUT/"
fi

# DIST/OTA specific operations:
if [ "$DIST_ENABLED" = true ]; then
    generate_ota_zip
fi
