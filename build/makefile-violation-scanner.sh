#!/bin/bash
#
# Copyright (c) 2019,2021 The Linux Foundation. All rights reserved.
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
# The Android.mk may contain one or more module.
# If any module includes kernel header file(s) then dependency rule should be added.
# The FAIL case condition: found_c_include=true && found_add_dep=false.
# The pass case condition: found_c_include=true && found_add_dep=true.
# By An 'exit 0' indicates success, while a non-zero exit value means missing dependency.
#

subdir="hardware/qcom vendor/qcom device/qcom"

cnt_module=0
cnt_kernel_error=0
cnt_shell_error=0
cnt_recursive_error=0
cnt_rm_error=0
cnt_datetime_error=0
cnt_target_product_error=0
cnt_is_product_in_list_error=0
cnt_ro_build_product_error=0

fnd_c_include=false
fnd_add_dep=false
fnd_shell_use=false
fnd_recursive_use=false
fnd_rm_use=false
fnd_datetime_use=false
fnd_target_product_use=false
fnd_is_product_in_list_use=false
fnd_ro_build_product_use=false

kernel_array=()
shell_array=()
recursive_array=()
rm_array=()
datetime_array=()
target_product_array=()
is_product_in_list_array=()
ro_build_product_array=()

function reset_flags () {
    fnd_c_include=false
    fnd_add_dep=false
    fnd_shell_use=false
    fnd_recursive_use=false
    fnd_rm_use=false
    fnd_datetime_use=false
    fnd_target_product_use=false
    fnd_is_product_in_list_use=false
    fnd_ro_build_product_use=false
}

function print_violations () {
    if [[ ${#kernel_array[@]} -gt 0 ]]; then
        echo "-----------------------------------------------------"
        echo "cnt_kernel_error : $cnt_kernel_error"
        echo "Error: Missing LOCAL_ADDITIONAL_DEPENDENCIES in below modules."
        echo "please use LOCAL_ADDITIONAL_DEPENDENCIES += \$(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr"
        for i in "${kernel_array[@]}"; do
            file_module=($i)
            echo "    Module: ${file_module[1]} in ${file_module[0]}"
        done
        echo "-----------------------------------------------------"
    fi
    if [[ ${#shell_array[@]} -gt 0 ]]; then
        echo "-----------------------------------------------------"
        echo "cnt_shell_error : $cnt_shell_error"
        echo "Error: Using \$(shell) in below files. Please remove usage of \$(shell)"
        for i in "${shell_array[@]}"; do
            echo "    $i"
        done
        echo "-----------------------------------------------------"
    fi
    if [[ ${#recursive_array[@]} -gt 0 ]]; then
        echo "-----------------------------------------------------"
        echo "cnt_recursive_error : $cnt_recursive_error"
        echo "Warning: Using recursive assignment (=) in below files."
        echo "please review use of recursive assignment and convert to simple assignment (:=) if necessary."
        for i in "${recursive_array[@]}"; do
            echo "    $i"
        done
        echo "-----------------------------------------------------"
    fi
    if [[ ${#rm_array[@]} -gt 0 ]]; then
        echo "-----------------------------------------------------"
        echo "cnt_rm_error : $cnt_rm_error"
        echo "Warning: Using rm in below makefiles. Please remove use of rm to prevent recompilation."
        for i in "${rm_array[@]}"; do
            echo "    $i"
        done
        echo "-----------------------------------------------------"
    fi
    if [[ ${#datetime_array[@]} -gt 0 ]]; then
        echo "-----------------------------------------------------"
        echo "cnt_datetime_error : $cnt_datetime_error"
        echo "Warning: Using CFLAG -Wno-error=date-time in below makefiles. This may lead to varying build output."
        echo "Please remove use of this CFLAG."
        for i in "${datetime_array[@]}"; do
            echo "    $i"
        done
        echo "-----------------------------------------------------"
    fi

    if [[ ${#target_product_array[@]} -gt 0 ]]; then
        echo "-----------------------------------------------------"
        echo "cnt_target_product_error : $cnt_target_product_error"
        echo "Warning: Using TARGET_PRODUCT in below makefiles. Please replace them with TARGET_BOARD_PLATFORM"
        for i in "${target_product_array[@]}"; do
            echo "    $i"
        done
        echo "-----------------------------------------------------"
    fi

    if [[ ${#is_product_in_list_array[@]} -gt 0 ]]; then
        echo "-----------------------------------------------------"
        echo "cnt_is_product_in_list_error : $cnt_is_product_in_list_error"
        echo "Warning: Using is-product-in-list in below makefiles. Please replace them with is-board-platform-in-list"
        for i in "${is_product_in_list_array[@]}"; do
            echo "    $i"
        done
        echo "-----------------------------------------------------"
    fi

    if [[ ${#ro_build_product_array[@]} -gt 0 ]]; then
        echo "-----------------------------------------------------"
        echo "cnt_ro_build_product_error : $cnt_ro_build_product_error"
        echo "Warning: Using ro.build.product in below makefiles. Please replace them with ro.board.platform"
        for i in "${ro_build_product_array[@]}"; do
            echo "    $i"
        done
        echo "-----------------------------------------------------"
    fi
}

function check_if_error() {
    if [[ "$fnd_add_dep" == false && "$fnd_c_include" == true ]]; then
        cnt_kernel_error=$((cnt_kernel_error+1))
        kernel_array+=("$1 $2")
    fi

    if [[ "$fnd_shell_use" == true ]]; then
        shell_array+=("$1")
    fi

    if [[ "$fnd_recursive_use" == true ]]; then
        recursive_array+=("$1")
    fi

    if [[ "$fnd_rm_use" == true ]]; then
        rm_array+=("$1")
    fi

    if [[ "$fnd_datetime_use" == true ]]; then
        datetime_array+=("$1")
    fi

    if [[ "$fnd_target_product_use" == true ]]; then
        target_product_array+=("$1")
    fi

    if [[ "$fnd_is_product_in_list_use" == true ]]; then
        is_product_in_list_array+=("$1")
    fi

    if [[ "$fnd_ro_build_product_use" == true ]]; then
        ro_build_product_array+=("$1")
    fi
}

function check_kernel_dep(){
    case $1 in
    LOCAL_C_INCLUDES*KERNEL_OBJ/usr*)
        fnd_c_include=true
        ;;
    LOCAL_ADDITIONAL_DEPENDENCIES*KERNEL_OBJ/usr*)
        fnd_add_dep=true
        ;;
    *CLEAR_VARS*)
        if [[ "$cnt_module" -gt 0 ]]; then
            if [[ "$fnd_add_dep" == false && "$fnd_c_include" == true ]]; then
                cnt_kernel_error=$((cnt_kernel_error+1))
                kernel_array+=("$2 $cnt_module")
            fi
        fi
        fnd_c_include=false
        fnd_add_dep=false
        cnt_module=$((cnt_module+1))
        ;;
    esac
}

function check_shell_use(){
    case $1 in
    *\$\(shell*)
        fnd_shell_use=true
        cnt_shell_error=$((cnt_shell_error+1))
        ;;
    esac
}

function check_recursive(){
    case $1 in
    *[:+?=\>\<]=*)
        ;;
    *=*)
        fnd_recursive_use=true
        cnt_recursive_error=$((cnt_recursive_error+1))
        ;;
    esac
}

function check_rm(){
    case $1 in
    *[[:space:]@^]rm[[:space:]]*)
        fnd_rm_use=true
        cnt_rm_error=$((cnt_rm_error+1))
        ;;
    esac
}

function check_datetime(){
    case $1 in
    *-Wno-error=date-time*)
        fnd_datetime_use=true
        cnt_datetime_error=$((cnt_datetime_error+1))
        ;;
    esac
}

function check_target_product_related(){
    case $1 in
    *\$\(TARGET_PRODUCT* | *\'TARGET_PRODUCT\'* | *\$TARGET_PRODUCT*)
        fnd_target_product_use=true
        cnt_target_product_error=$((cnt_target_product_error+1))
        ;;&
    *is-product-in-list*)
        fnd_is_product_in_list_use=true
        cnt_is_product_in_list_error=$((cnt_is_product_in_list_error+1))
        ;;
    *ro.build.product*)
        fnd_ro_build_product_use=true
        cnt_ro_build_product_error=$((cnt_ro_build_product_error+1))
        ;;
    esac
}

function is_in_whitelist(){
    for element in ${array_target_product_related_whitelist[@]}; do
        case $1 in
        $element*)
            return 1
            ;;
        esac
    done
    return 0
}

function scan_files(){
    for i in "${array[@]}"; do
       if [[ $i == *"Android.mk" ]]; then
           if is_in_whitelist $i == 0; then
                while read line; do
                    case $line in
                    \#*)
                        continue
                        ;;
                    *)
                        check_kernel_dep "$line" "$i"
                        check_shell_use "$line"
                        check_recursive "$line"
                        check_rm "$line"
                        check_datetime "$line"
                        check_target_product_related "$line"
                    esac
                done < $i
           else
                while read line; do
                    case $line in
                    \#*)
                        continue
                        ;;
                    *)
                        check_kernel_dep "$line" "$i"
                        check_shell_use "$line"
                        check_recursive "$line"
                        check_rm "$line"
                        check_datetime "$line"
                    esac
                done < $i
            fi
       else
            if is_in_whitelist $i == 0; then
                while read line; do
                    case $line in
                    \#*)
                        continue
                        ;;
                    *)
                        check_target_product_related "$line"
                    esac
                done < $i
            fi
        fi
        check_if_error "$i" "$cnt_module"
        cnt_module=0
        reset_flags
    done

    print_violations

   # exit 1 for error or exit 0 for warning
    if [[ "$BUILD_REQUIRES_KERNEL_DEPS" == "true" && "$cnt_kernel_error" -gt 0 ]]; then
        exit 1
    elif [[ "$BUILD_BROKEN_USES_SHELL" != "true" && "$cnt_shell_error" -gt 0 ]]; then
        exit 1
    elif [[ "$BUILD_BROKEN_USES_RECURSIVE_VARS" != "true" && "$cnt_recursive_error" -gt 0 ]]; then
        exit 1
    elif [[ "$BUILD_BROKEN_USES_RM_OUT" != "true" && "$cnt_rm_error" -gt 0 ]]; then
        exit 1
    elif [[ "$BUILD_BROKEN_USES_DATETIME" != "true" && "$cnt_datetime_error" -gt 0 ]]; then
        exit 1
    elif [[ "$BUILD_BROKEN_USES_TARGET_PRODUCT" != "true" &&
        ("$cnt_target_product_error" -gt 0 || "$cnt_is_product_in_list_error" -gt 0 || "$cnt_ro_build_product_error" -gt 0 ) ]]; then
        exit 1
    else
        exit 0
    fi
}
echo "-----------------------------------------------------"
echo " Checking makefile errors "
echo "      Checking dependency on kernel headers ......"
echo "      Checking \$(shell) usage ......"
echo "      Checking recursive usage ......"
echo "      Checking rm usage ......"
echo "      Checking -Wno-error=date-time usage ......"
echo "      Checking TARGET_PRODUCT usage ......"
echo "      Checking is-product-in-list usage ......"
echo "      Checking ro.build.product usage ......"
echo "-----------------------------------------------------"

while IFS= read -r line; do
    eval $(echo "$line" | tr -d :)
done < vendor/qcom/opensource/core-utils/build/makefile_violation_config.mk

FILES=`find ${subdir} -type f \( -iname '*.mk' -o -iname '*.sh' -o -iname '*.py' \)`
for file in $FILES ; do
    array+=("$file")
done

# Load whitelist files to ignore TARGET_PRODUCT/is-product-in-list/ro.build.product enforcement check
while IFS= read -r line; do
    array_target_product_related_whitelist+=("$line")
done < vendor/qcom/opensource/core-utils/build/target_product_related_enforcement.whitelist

scan_files
