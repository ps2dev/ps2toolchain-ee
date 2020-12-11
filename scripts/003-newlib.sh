#!/bin/bash
# 003-newlib.sh by Francisco Javier Trujillo Mata (fjtrujy@gmail.com)

## Download the source code.
REPO_URL="https://github.com/ps2dev/newlib.git"
REPO_FOLDER="newlib"
BRANCH_NAME="ee-v4.0.0"
if test ! -d "$REPO_FOLDER"; then
	git clone --depth 1 -b $BRANCH_NAME $REPO_URL && cd $REPO_FOLDER || exit 1
else
	cd $REPO_FOLDER && git fetch origin && git reset --hard origin/${BRANCH_NAME} || exit 1
fi

TARGET_ALIAS="ee" 
TARGET="mips64r5900el-ps2-elf"

## Determine the maximum number of processes that Make can work with.
PROC_NR=$(getconf _NPROCESSORS_ONLN)

## Create and enter the toolchain/build directory
mkdir build-$TARGET && cd build-$TARGET || { exit 1; }

## Configure the build.
CFLAGS_FOR_TARGET="-G0" ../configure --prefix="$PS2DEV/$TARGET_ALIAS" --target="$TARGET" || { exit 1; }

## Compile and install.
make clean && make -j $PROC_NR && make install && make clean || { exit 1; }
