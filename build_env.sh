#!/bin/sh

CC_DIR="$NDK/toolchains/$FOL-4.9/prebuilt/linux-x86_64/bin"

CROSS_COMPILE="$CC_DIR/$ARCH-"
CC="${CROSS_COMPILE}gcc"
CXX="${CROSS_COMPILE}g++"
LD="${CROSS_COMPILE}ld"

CFLAGS="-Os -ggdb -static --sysroot=$SYSROOT"
CXXFLAGS="$CFLAGS"
CPPFLAGS="--sysroot=$SYSROOT"
LDFLAGS="--sysroot=$SYSROOT -static"

export CROSS_COMPILE CC CXX LD CPPFLAGS CFLAGS CXXFLAGS LDFLAGS
exec "$@"

