#!/bin/bash

ANDROID_SDK_DIR=/Users/palmerc/Development/android-sdk
ANDROID_NDK_PREFIX=/Users/palmerc/Development/android-ndk/standalone-r13b
ANDROID_AVD_PREFIX=nexus19

DCMTK_BASE_DIR=${HOME}/Development/dcmtk-compile
DCMTK_BUILD_DIR=${DCMTK_BASE_DIR}/dcmtk-build
DCMTK_SOURCE_DIR=${DCMTK_BASE_DIR}/dcmtk.old
DCMTK_INSTALL_DIR=${DCMTK_BASE_DIR}/dcmtk
LIBICONV_BASE_DIR=${DCMTK_BASE_DIR}/libiconv

declare -a COMPILE_ARCHITECTURES=("arm" "armv7a" "x86")
SAVED_PATH=${PATH}

BUILD_PARENT_DIR=${DCMTK_BUILD_DIR%/${DCMTK_BUILD_DIR##*/}}

export PATH=${ANDROID_SDK_DIR}/tools:${PATH}

for ARCH in "${COMPILE_ARCHITECTURES[@]}"
do
    ANDROID_ABI=""
    ANDROID_ABI_SHORTNAME=""
    COMPILER_GROUP=""
    case ${ARCH} in
        "arm" )
            ANDROID_ABI=armeabi
            ANDROID_ABI_SHORTNAME="armeabi"
            COMPILER_GROUP="arm"
            ;;
        "armv7a" )
            ANDROID_ABI="armeabi-v7a with NEON"
            ANDROID_ABI_SHORTNAME="armeabi-v7a"
            COMPILER_GROUP="arm"
            ;;
        "x86" )
            ANDROID_ABI=x86
            ANDROID_ABI_SHORTNAME="x86"
            COMPILER_GROUP="x86"
            ;;
    esac

    cd ${BUILD_PARENT_DIR}
    rm -rf ${DCMTK_BUILD_DIR}
    mkdir ${DCMTK_BUILD_DIR}
    pushd ${DCMTK_BUILD_DIR}

    LIBICONV_DIR=${LIBICONV_BASE_DIR}/${ANDROID_ABI_SHORTNAME}
    export ANDROID_STANDALONE_TOOLCHAIN=${ANDROID_NDK_PREFIX}-${COMPILER_GROUP}
    echo "Kill running emulators"
    adb devices | grep emulator | cut -f 1 | xargs -I '{}' adb -s {} emu kill 

    cmake \
        -DCMAKE_TOOLCHAIN_FILE=${DCMTK_SOURCE_DIR}/CMake/android.toolchain.cmake \
        -DCMAKE_INSTALL_PREFIX=${DCMTK_INSTALL_DIR}/${ANDROID_ABI_SHORTNAME} \
        -DDCMTK_ANDROID_TOOLCHAIN_VERIFIED=TRUE \
        -DBUILD_APPS=FALSE \
        -DANDROID_SDK_ROOT=${ANDROID_SDK_DIR} \
        -DANDROID_NATIVE_API_LEVEL=android-19 \
        -DANDROID_EMULATOR_AVD=${ANDROID_AVD_PREFIX}-${COMPILER_GROUP} \
        -DANDROID_ABI="${ANDROID_ABI}" \
        -DANDROID_STL=gnustl_shared \
        -DLIBCHARSET_LIBRARY=${LIBICONV_DIR}/lib/libcharset.a \
        -DLIBCHARSET_INCLUDE_DIR=${LIBICONV_DIR}/include \
        -DLIBICONV_LIBRARY=${LIBICONV_DIR}/lib/libiconv.a \
        -DLIBICONV_INCLUDE_DIR=${LIBICONV_DIR}/include \
        ${DCMTK_SOURCE_DIR}

    make -j8 
    make install
    popd
done

export PATH=${SAVED_PATH}
