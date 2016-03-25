#!/bin/bash

 #
 # Copyright � 2016, Akash Hiremath "akash akya" <akashh246@gmail.com>
 # Custom build script
 #
 # This software is licensed under the terms of the GNU General Public
 # License version 2, as published by the Free Software Foundation, and
 # may be copied, distributed, and modified under those terms.
 #
 # This program is distributed in the hope that it will be useful,
 # but WITHOUT ANY WARRANTY; without even the implied warranty of
 # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 # GNU General Public License for more details.
 #
 #

#Define Variables
SOURCE_DIR="/home/akash/Android/redmi2/android_kernel_cyanogen_msm8916-cm-13.0-wt88047"
ZIP_DIR=$SOURCE_DIR"/../zip"

export ARCH=arm
export SUBARCH=arm
export CROSS_COMPILE='/home/akash/Android/arm-eabi-4.8/bin/arm-eabi-'
export KBUILD_BUILD_USER="akash"
export KBUILD_BUILD_HOST="steins-gate"

COLOR_NC='\e[0m' # No Color
COLOR_WHITE='\e[0;37m'
COLOR_BLACK='\e[0;30m'
COLOR_BLUE='\e[0;34m'
COLOR_LIGHT_BLUE='\e[0;34m'
COLOR_GREEN='\e[0;32m'
COLOR_LIGHT_GREEN='\e[0;32m'
COLOR_CYAN='\e[0;36m'
COLOR_LIGHT_CYAN='\e[0;36m'
COLOR_RED='\e[0;31m'
COLOR_LIGHT_RED='\e[0;31m'
COLOR_PURPLE='\e[0;35m'
COLOR_LIGHT_PURPLE='\e[0;35m'
COLOR_BROWN='\e[0;33m'
COLOR_YELLOW='\e[0;33m'
COLOR_GRAY='\e[0;30m'
COLOR_LIGHT_GRAY='\e[0;37m'

if [ "$1" == "clean" ];
    then
    echo -e "$COLOR_YELLOW*******************************************"
    echo -e "          Cleaning the build" 
    echo -e "*******************************************"
    make clean && make mrproper
else
    #delete old things
    if [ -f $ZIP_DIR/zImage ];
    then
        rm -f $ZIP_DIR/zImage
        rm -f $ZIP_DIR/dt.img
        rm -f $ZIP_DIR/*.zip
    fi

    BUILD_START=$(date +"%s")

    if [ -f $SOURCE_DIR/arch/arm/boot/zImage ];
    then
        rm $SOURCE_DIR/arch/arm/boot/zImage
        rm $SOURCE_DIR/arch/arm/boot/dt.img
    fi

    echo -e "$COLOR_CYAN*******************************************"
    echo -e "          Initialize Defconfig" 
    echo -e "*******************************************"
    make microfire_defconfig

    echo -e "$COLOR_YELLOW\n\n*******************************************"
    echo -e "             Building Kernel"
    echo -e "*******************************************"
    make -j5

    if [ -f $SOURCE_DIR/arch/arm/boot/zImage ];
    then
        echo -e "Build complete."
        echo -e "$blue\n\n*******************************************"
        echo -e "       Creating flashable package"
        echo -e "*******************************************"
        
        echo -e "Creating dt.img from device tree"

        KPATH=$SOURCE_DIR"/arch/arm/boot"
        dtbToolCM -2 -o $KPATH"/dt.img" -s 2048 -p $SOURCE_DIR"/scripts/dtc/" $KPATH"/dts/" > /dev/null

        if [ -f $SOURCE_DIR/arch/arm/boot/dt.img ];
        then
            echo -e "Copying kernel and device tree"
            cp $SOURCE_DIR/arch/arm/boot/zImage $ZIP_DIR
            cp $SOURCE_DIR/arch/arm/boot/dt.img $ZIP_DIR

            echo -e "\n- Compressing Kernel zip"

            KERNEL="microfire"
            RELEASE="beta"
            REL_DIR=$SOURCE_DIR"/../Kernel-Release"
            cd $ZIP_DIR
            
            FILE_NAME=$KERNEL-$RELEASE-$(date +"%Y%m%d-%H%M").zip
            echo -e "Creating package : $FILE_NAME"
            zip -r -q $FILE_NAME *

            if [ -f $ZIP_DIR/$FILE_NAME ];
            then
                echo -e "Package Complete : $FILE_NAME"
                echo -e "\n- Copying Generated zip to Release folder"
                cp $FILE_NAME $REL_DIR
            else
                echo -e "$COLOR_RED\nPackage Failed"
            fi
            cd $SOURCE_DIR

            BUILD_END=$(date +"%s")
            DIFF=$(($BUILD_END - $BUILD_START))
            echo -e "Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
        else
            echo -e "$COLOR_RED \nError can not create dt.img!"   
        fi
    else
        echo -e "$COLOR_RED \n\nCompilation failed! Fix the errors!"
    fi
fi