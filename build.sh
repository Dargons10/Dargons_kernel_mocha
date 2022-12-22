#!/bin/bash
export ARCH="arm"
export KBUILD_BUILD_HOST="v5.00"
export KBUILD_BUILD_USER="Dargons10"

clean_build=0
config="tegra12_android_defconfig"
dtb_name="tegra124-mocha.dtb"
dtb_only=0
kernel_name=$(git rev-parse --abbrev-ref HEAD)
threads=5
toolchain="$HOME/gcc/linux-x86/arm/arm-eabi-4.8/bin/arm-eabi-"

KERNEL_DIR=$PWD
ORIGINAL_OUTPUT_DIR="$KERNEL_DIR/arch/$ARCH/boot"
OUTPUT_DIR="$KERNEL_DIR/output"

ERROR=0
HEAD=1
WARNING=2

function printfc() {
	if [[ $2 == $ERROR ]]; then
		printf "\e[1;31m$1\e[0m"
		return
	fi;
	if [[ $2 == $HEAD ]]; then
		printf "\e[1;32m$1\e[0m"
		return
	fi;
	if [[ $2 == $WARNING ]]; then
		printf "\e[1;35m$1\e[0m"
		return
	fi;
}

function generate_version()

{
	echo -e "\n\e[95mCleaning up..."
	mkdir -p $OUT_DIR $BUILDING_DIR $MODULES_DIR
	echo -e "\e[34mAll clean!"
}

FUNC_COMPILE()
{
	echo -e "\n\e[95mStarting the build..."
	make -C $R O=$BUILDING_DIR $DEFCONFIG 
	make -j$JOBS -C $R O=$BUILDING_DIR ARCH=arm CROSS_COMPILE=$CROSS_COMPILER
	make tegra124-mocha.dtb -C $R O=$BUILDING_DIR ARCH=arm CROSS_COMPILE=$CROSS_COMPILER
	cp $OUT_DIR/kernel_obj/arch/arm/boot/zImage $OUT_DIR/zImage
	cp $OUT_DIR/kernel_obj/arch/arm/boot/dts/tegra124-mocha.dtb $OUT_DIR/mocha.dtb
	echo -e "\e[34mJob done!"

	echo -e "\n\e[95mCopying the Modules..."
	rm -rf $MODULES_DIR
	mkdir $MODULES_DIR
	find . -name "*.ko" -exec cp {} $MODULES_DIR \;
	echo -e "\e[34mDone!"
}

echo -e -n "\e[33mDo you want to clean build directory (y/n)? "
old_stty_cfg=$(stty -g)
stty raw -echo
answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
stty $old_stty_cfg

if echo "$answer" | grep -iq "^y" ;then
    FUNC_CLEANUP
    FUNC_COMPILE
else
    rm -r $OUT_DIR/zImage
    FUNC_COMPILE
    
fi
