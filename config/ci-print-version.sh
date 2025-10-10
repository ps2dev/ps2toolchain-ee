#!/bin/bash

export PS2DEV=$PWD/ps2dev
export PATH=$PATH:$PS2DEV/ee/bin
mips64r5900el-ps2-elf-as --version
mips64r5900el-ps2-elf-ld --version
mips64r5900el-ps2-elf-gcc --version
