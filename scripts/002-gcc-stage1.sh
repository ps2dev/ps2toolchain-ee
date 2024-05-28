#!/bin/bash
# 002-gcc-stage1.sh by ps2dev developers

## Exit with code 1 when any command executed returns a non-zero exit code.
onerr()
{
  exit 1;
}
trap onerr ERR

TARGET_ALIAS="ee"
TARG_XTRA_OPTS=""
TARGET_CFLAGS="-O2 -gdwarf-2 -gz"
OSVER=$(uname)

## Create a temporal folder where to build the phase 1 of the toolchain.
TMP_TOOLCHAIN_BUILD_DIR=$(pwd)/tmp_toolchain_build
rm -rf "${TMP_TOOLCHAIN_BUILD_DIR}" && mkdir "${TMP_TOOLCHAIN_BUILD_DIR}"
## Copy toolchain content ($PS2DEV) to the temporal folder.
cp -r "${PS2DEV}/" "${TMP_TOOLCHAIN_BUILD_DIR}"

## Add the toolchain to the PATH.
export PATH="$TMP_TOOLCHAIN_BUILD_DIR/$TARGET_ALIAS/bin:$PATH"

## Read information from the configuration file.
source "$(dirname "$0")/../config/ps2toolchain-ee-config.sh"

## Download the source code.
REPO_URL="$PS2TOOLCHAIN_EE_GCC_REPO_URL"
REPO_REF="$PS2TOOLCHAIN_EE_GCC_DEFAULT_REPO_REF"
REPO_FOLDER="$(s="$REPO_URL"; s=${s##*/}; printf "%s" "${s%.*}")"

# Checking if a specific Git reference has been passed in parameter $1
if test -n "$1"; then
  REPO_REF="$1"
  printf 'Using specified repo reference %s\n' "$REPO_REF"
fi

if test ! -d "$REPO_FOLDER"; then
  git clone --depth 1 -b "$REPO_REF" "$REPO_URL" "$REPO_FOLDER"
else
  git -C "$REPO_FOLDER" fetch origin
  git -C "$REPO_FOLDER" reset --hard "origin/$REPO_REF"
  git -C "$REPO_FOLDER" checkout "$REPO_REF"
fi

cd "$REPO_FOLDER"

## If using MacOS Apple, set gmp, mpfr and mpc paths using TARG_XTRA_OPTS 
## (this is needed for Apple Silicon but we will do it for all MacOS systems)
if [ "$(uname -s)" = "Darwin" ]; then
  ## Check if using brew
  if command -v brew &> /dev/null; then
    TARG_XTRA_OPTS="--with-gmp=$(brew --prefix gmp) --with-mpfr=$(brew --prefix mpfr) --with-mpc=$(brew --prefix libmpc)"
  elif command -v port &> /dev/null; then
  ## Check if using MacPorts
    MACPORT_BASE=$(dirname `port -q contents gmp|grep gmp.h`|sed s#/include##g)
    echo Macport base is $MACPORT_BASE
    TARG_XTRA_OPTS="--with-gmp=$MACPORT_BASE --with-mpfr=$MACPORT_BASE --with-mpc=$MACPORT_BASE"
  fi
fi

## Determine the maximum number of processes that Make can work with.
PROC_NR=$(getconf _NPROCESSORS_ONLN)

## For each target...
for TARGET in "mips64r5900el-ps2-elf"; do
  ## Create and enter the toolchain/build directory
  rm -rf "build-$TARGET-stage1"
  mkdir "build-$TARGET-stage1"
  cd "build-$TARGET-stage1"

  ## Configure the build.
  CFLAGS_FOR_TARGET="$TARGET_CFLAGS" \
  ../configure \
    --quiet \
    --prefix="$TMP_TOOLCHAIN_BUILD_DIR/$TARGET_ALIAS" \
    --target="$TARGET" \
    --enable-languages="c" \
    --with-float=hard \
    --without-headers \
    --without-newlib \
    --disable-libssp \
    --disable-multilib \
    --disable-nls \
    --disable-tls \
    $TARG_XTRA_OPTS

  ## Compile and install.
  make --quiet -j "$PROC_NR" all
  make --quiet -j "$PROC_NR" install-strip
  make --quiet -j "$PROC_NR" clean

  ## Exit the build directory.
  cd ..

  ## End target.
done
