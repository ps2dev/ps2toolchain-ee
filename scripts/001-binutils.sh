#!/bin/bash
# 001-binutils.sh by Francisco Javier Trujillo Mata (fjtrujy@gmail.com)

## Download the source code.
REPO_URL="https://github.com/ps2dev/binutils-gdb.git"
REPO_FOLDER="binutils-gdb"
BRANCH_NAME="ee-v2.36.0"
if test ! -d "$REPO_FOLDER"; then
  git clone --depth 1 -b $BRANCH_NAME $REPO_URL && cd "$REPO_FOLDER" || exit 1
else
  cd "$REPO_FOLDER" && git fetch origin && git reset --hard "origin/${BRANCH_NAME}" && git checkout "$BRANCH_NAME" || exit 1
fi

TARGET_ALIAS="ee"
TARGET="mips64r5900el-ps2-elf"
TARG_XTRA_OPTS=""
OSVER=$(uname)

if [ "${OSVER:0:10}" == MINGW64_NT ]; then
  export lt_cv_sys_max_cmd_len=8000
  export CC=x86_64-w64-mingw32-gcc
  TARG_XTRA_OPTS="--host=x86_64-w64-mingw32"
elif [ "${OSVER:0:10}" == MINGW32_NT ]; then
  export lt_cv_sys_max_cmd_len=8000
  export CC=i686-w64-mingw32-gcc
  TARG_XTRA_OPTS="--host=i686-w64-mingw32"
fi

## Determine the maximum number of processes that Make can work with.
PROC_NR=$(getconf _NPROCESSORS_ONLN)

## Create and enter the toolchain/build directory
rm -rf build-$TARGET && mkdir build-$TARGET && cd build-$TARGET || { exit 1; }

## Configure the build.
../configure \
  --quiet \
  --prefix="$PS2DEV/$TARGET_ALIAS" \
  --target="$TARGET" \
  --disable-separate-code \
  --disable-sim \
  --disable-nls \
  $TARG_XTRA_OPTS || { exit 1; }

## Compile and install.
make --quiet -j $PROC_NR clean          || { exit 1; }
make --quiet -j $PROC_NR CFLAGS="$CFLAGS -D_FORTIFY_SOURCE=0" || { exit 1; }
make --quiet -j $PROC_NR install-strip  || { exit 1; }
make --quiet -j $PROC_NR clean          || { exit 1; }
