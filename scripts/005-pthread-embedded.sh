#!/bin/bash
# 005-pthread-embedded.sh by ps2dev developers

## Exit with code 1 when any command executed returns a non-zero exit code.
onerr()
{
  exit 1;
}
trap onerr ERR

## Read information from the configuration file.
source "$(dirname "$0")/../config/ps2toolchain-ee-config.sh"

## Download the source code.
REPO_URL="$PS2TOOLCHAIN_EE_PTHREAD_EMBEDDED_REPO_URL"
REPO_REF="$PS2TOOLCHAIN_EE_PTHREAD_EMBEDDED_DEFAULT_REPO_REF"
REPO_FOLDER="$(s="$REPO_URL"; s=${s##*/}; printf "%s" "${s%.*}")"

# Checking if a specific Git reference has been passed in parameter $1
if test -n "$1"; then
  REPO_REF="$1"
  printf 'Using specified repo reference %s\n' "$REPO_REF"
fi

if test ! -d "$REPO_FOLDER"; then
  git clone --depth 1 -b "$REPO_REF" "$REPO_URL" "$REPO_FOLDER"
else
  git -C "$REPO_FOLDER" remote set-url origin "$REPO_URL"
  git -C "$REPO_FOLDER" fetch origin "$REPO_REF" --depth=1
  git -C "$REPO_FOLDER" checkout -f FETCH_HEAD
fi

cd "$REPO_FOLDER"

TARGET_ALIAS="ee"
TARG_XTRA_OPTS=""
OSVER=$(uname)

## Determine the maximum number of processes that Make can work with.
PROC_NR=$(getconf _NPROCESSORS_ONLN)

## For each target...
for TARGET in "mips64r5900el-ps2-elf"; do
  cd platform/ps2

  ## Compile and install.
  make --quiet -j "$PROC_NR" all
  make --quiet -j "$PROC_NR" install
  make --quiet -j "$PROC_NR" clean

  ## Exit the build directory.
  cd ../..

  ## End target.
done
