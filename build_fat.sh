#!/bin/bash

ARCH=$1
FULL_ARCH_NAME=$1

if [ "${FULL_ARCH_NAME}" = "x64" ]; then
    echo "Normalizing arch to x86_64"
    FULL_ARCH_NAME=x86_64
fi

ANDROID_NDK=/home/cosnita/work/ndk12b/android-ndk-r12b

declare -A BUILDTOOLS=(
    ["arm"]=$ANDROID_NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/arm-linux-androideabi/bin
    ["arm64"]=$ANDROID_NDK/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64/aarch64-linux-android/bin
    ["ia32"]=$ANDROID_NDK/toolchains/x86-4.9/prebuilt/linux-x86_64/i686-linux-android/bin
    ["x86_64"]=$ANDROID_NDK/toolchains/x86_64-4.9/prebuilt/linux-x86_64/x86_64-linux-android/bin
)

CURRENT_BUILD_TOOL=${BUILDTOOLS[${FULL_ARCH_NAME}]}

V8_LIBS_PATH=./out/android_$ARCH.release/obj.target/src
declare -a lib_files
lib_files=($(ls -d -1 $V8_LIBS_PATH/*\.a | grep -e "\.a"))

###### for each found library generate fat equivalent
for current_element in ${lib_files[@]};
do
	# take only the filename from the absolute path
	(filename="${current_element##*/}"

	# get the list of all files from the current tin file
	$CURRENT_BUILD_TOOL/ar t $current_element | \

	# replace every streamed file in the new file
	xargs -L1  $CURRENT_BUILD_TOOL/ar r dist/release/${FULL_ARCH_NAME}/$filename) \
done
