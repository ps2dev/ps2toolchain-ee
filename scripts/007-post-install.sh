#!/bin/bash
# 007-post-install.sh by ps2dev developers

## Exit with code 1 when any command executed returns a non-zero exit code.
onerr()
{
  exit 1;
}
trap onerr ERR

TARGET_ALIAS="ee"
TARGET="mips64r5900el-ps2-elf"

# Remove generated dummy crt0.o file
rm -rf "$PS2DEV/$TARGET_ALIAS/$TARGET/lib/crt0.o"
