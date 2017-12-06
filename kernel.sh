#!/bin/bash

# Bash Color
green='\033[01;32m'
red='\033[01;31m'
blink_red='\033[05;31m'
restore='\033[0m'

clear

# Resources
THREAD="-j$(grep -c ^processor /proc/cpuinfo)"
KERNEL="Image.gz-dtb"
# DTBIMAGE="dtb"
DEFCONFIG="msmcortex-perf_defconfig"
#"msmcortex_defconfig"
#"msmcortex-perf_defconfig"

# Kernel Details
BASE_AK_VER="0.1"
VER=".CM12.1"
AK_VER="$BASE_AK_VER$VER"

# Vars

export CROSS_COMPILE=${HOME}/uber/out/aarch64-linux-android-4.9-kernel/bin/aarch64-linux-android-
#/lineageos/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android-
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER=jgcaap
export KBUILD_BUILD_HOST=kernel

# Paths
KERNEL_DIR=`pwd`
REPACK_DIR="${HOME}/new/anykernel"
PATCH_DIR="${HOME}/new/anykernel"
MODULES_DIR="${HOME}/new/anykernel/modules"
ZIP_MOVE="${HOME}/new/out"
ZIMAGE_DIR="${HOME}/op5/out/arch/arm64/boot"

# Functions
function clean_all {
		rm -rf $MODULES_DIR/*
		cd $REPACK_DIR
		rm -rf $KERNEL
		rm -rf $DTBIMAGE
		cd $KERNEL_DIR
		echo
		make clean O=out  && make mrproper O=out
}

function make_kernel {
		echo
		make O=out $DEFCONFIG
		make O=out $THREAD
		cp -vr $ZIMAGE_DIR/$KERNEL $REPACK_DIR
}

function make_modules {
		rm `echo $MODULES_DIR"/*"`
		find $KERNEL_DIR -name '*.ko' -exec cp -v {} $MODULES_DIR \;
		cp ${HOME}/new/wifi/* -rf $MODULES_DIR
}

function make_dtb {
		/home/jorge/new/anykernel/tools/dtbToolCM -2 -o /home/jorge/new/anykernel/dtb -s 2048 -p /home/jorge/op5/scripts/dtc/ /home/jorge/op5/arch/arm/boot/
}

function make_zip {
		cd $REPACK_DIR
		mv Image.gz-dtb zImage
		zip -r9 newKernel-CM12-"$VARIANT".zip *
		mv newKernel-CM12-"$VARIANT".zip $ZIP_MOVE
		cd $KERNEL_DIR
}


DATE_START=$(date +"%s")

echo -e "${green}"
echo "New Kernel Creation Script:"
echo -e "${restore}"

while read -p "Do you want to clean stuffs (y/n)? " cchoice
do
case "$cchoice" in
	y|Y )
		clean_all
		echo
		echo "All Cleaned now."
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done

echo

while read -p "Do you want to build kernel (y/n)? " dchoice
do
case "$dchoice" in
	y|Y)
		make_kernel
		make_dtb
		make_modules
		make_zip
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done

echo -e "${green}"
echo "-------------------"
echo "Build Completed in:"
oecho "-------------------"
echo -e "${restore}"

DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
echo
mv ~/new/out/newKernel-CM12-.zip ~/files/oneplus5t/kernel/newKernel-OOS-1.03.zip
#/etc/script/md5.sh
