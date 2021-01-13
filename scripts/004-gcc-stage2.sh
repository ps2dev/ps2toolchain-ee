#!/bin/bash
# 004-gcc-stage2.sh by Francisco Javier Trujillo Mata (fjtrujy@gmail.com)

## Download the source code.
REPO_URL="https://github.com/ps2dev/gcc.git"
REPO_FOLDER="gcc"
BRANCH_NAME="ee-v10.2.0"
if test ! -d "$REPO_FOLDER"; then
	git clone --depth 1 -b $BRANCH_NAME $REPO_URL && cd $REPO_FOLDER || exit 1
else
	cd $REPO_FOLDER && git fetch origin && git reset --hard origin/${BRANCH_NAME} || exit 1
fi

TARGET_ALIAS="ee" 
TARGET="mips64r5900el-ps2-elf"

OSVER=$(uname)
## Apple needs to pretend to be linux
if [ ${OSVER:0:6} == Darwin ]; then
	TARG_XTRA_OPTS="--build=i386-linux-gnu --host=i386-linux-gnu --enable-cxx-flags=-G0"
else
	TARG_XTRA_OPTS="--enable-cxx-flags=-G0"
fi

## Determine the maximum number of processes that Make can work with.
PROC_NR=$(getconf _NPROCESSORS_ONLN)

## Create and enter the toolchain/build directory
rm -rf build-$TARGET-stage2 && mkdir build-$TARGET-stage2 && cd build-$TARGET-stage2 || { exit 1; }

## Configure the build.
../configure \
  --quiet \
  --prefix="$PS2DEV/$TARGET_ALIAS" \
  --target="$TARGET" \
  --enable-languages="c,c++" \
  --with-float=hard \
  --with-newlib \
  --disable-nls \
  --disable-shared \
  --disable-libssp \
  --disable-libmudflap \
  --disable-threads \
  --disable-libgomp \
  --disable-libquadmath \
  --disable-target-libiberty \
  --disable-target-zlib \
  --without-ppl \
  --without-cloog \
  --with-headers="$PS2DEV/$TARGET_ALIAS/$TARGET/include" \
  --disable-libada \
  --disable-libatomic \
  --disable-multilib \
  --disable-lto \
  $TARG_XTRA_OPTS || { exit 1; }

## Compile and install.
make --quiet -j $PROC_NR clean          || { exit 1; }
make --quiet -j $PROC_NR all            || { exit 1; }
make --quiet -j $PROC_NR install-strip  || { exit 1; }
make --quiet -j $PROC_NR clean          || { exit 1; }