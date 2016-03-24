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

#!/bin/bash
#Define Variables
SOURCE_DIR="/home/akash/Android/redmi2/android_kernel_cyanogen_msm8916-cm-13.0-wt88047"
ZIP_DIR=$SOURCE_DIR"/../zip"

#Main Process starts from here
blue='\033[0;34m'
cyan='\033[0;36m'
yellow='\033[0;33m'
red='\033[0;31m'
nocol='\033[0m'

#delete old things
if [ -f $ZIP_DIR/zImage ];
then
    rm -f $ZIP_DIR/zImage
    rm -f $ZIP_DIR/dt.img
    rm -f $ZIP_DIR/*.zip
fi

BUILD_START=$(date +"%s")

export ARCH=arm
export SUBARCH=arm
export CROSS_COMPILE='/home/akash/Android/arm-eabi-4.8/bin/arm-eabi-'
export KBUILD_BUILD_USER="akash"
export KBUILD_BUILD_HOST="steins-gate"

if [ -f $SOURCE_DIR/arch/arm/boot/zImage ];
then
    rm $SOURCE_DIR/arch/arm/boot/zImage
    rm $SOURCE_DIR/arch/arm/boot/dt.img
fi

echo "$cyan*******************************************"
echo "          Initialize Defconfig" 
echo "*******************************************"
make microfire_defconfig

echo "$yellow\n\n*******************************************"
echo "             Building Kernel"
echo "*******************************************"
make -j5

if [ -f $SOURCE_DIR/arch/arm/boot/zImage ];
then
    echo "Build complete."
    echo "$blue\n\n*******************************************"
    echo "       Creating flashable package"
    echo "*******************************************"
    
    echo "Creating dt.img from device tree"

    KPATH=$SOURCE_DIR"/arch/arm/boot"
    dtbToolCM -2 -o $KPATH"/dt.img" -s 2048 -p $SOURCE_DIR"/scripts/dtc/" $KPATH"/dts/" > /dev/null

    if [ -f $SOURCE_DIR/arch/arm/boot/dt.img ];
    then
        echo "Copying kernel and device tree"
        cp $SOURCE_DIR/arch/arm/boot/zImage $ZIP_DIR
        cp $SOURCE_DIR/arch/arm/boot/dt.img $ZIP_DIR

        echo "\n- Compressing Kernel zip"

        KERNEL="microfire"
        RELEASE="beta"
        REL_DIR=$SOURCE_DIR"/../Kernel-Release"
        cd $ZIP_DIR
        
        FILE_NAME=$KERNEL-$RELEASE-$(date +"%Y%m%d-%H%M").zip
        echo "Creating package : $FILE_NAME"
        zip -r -q $FILE_NAME *

        if [ -f $ZIP_DIR/$FILE_NAME ];
        then
            echo "Package Complete : $FILE_NAME"
            echo "\n- Copying Generated zip to Release folder"
            cp $FILE_NAME $REL_DIR
        else
            echo "$red\nPackage Failed"
        fi
        cd $SOURCE_DIR

        BUILD_END=$(date +"%s")
        DIFF=$(($BUILD_END - $BUILD_START))
        echo "Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
    else
        echo "$red \nError can not create dt.img!"   
    fi
else
    echo "$red \n\nCompilation failed! Fix the errors!"
fi