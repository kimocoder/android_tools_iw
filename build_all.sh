#!/bin/sh
set -e

input="$@"
[ "$input" ] || { echo -e "Enter arch!\nValid entries are arm, arm64, x86, and/or x64\nYou can enter multiple, for example: ./build_all.sh arm arm64 x86 x64"; exit 1; }

libnl_tgz="libnl-3.2.25.tar.gz"
libnl_url="http://www.infradead.org/~tgr/libnl/files/$libnl_tgz"

iw_txz="iw-5.9.tar.xz"
iw_url="https://kernel.org/pub/software/network/iw/$iw_txz"

libnl_dir="${libnl_tgz%.tar.gz}"
iw_dir="${iw_txz%.tar.xz}"
dir="$PWD"
export NDK="$dir/android-ndk-r11c"

if [ ! -d "$NDK" ]; then
	echo "Setting up NDK"
	[ -f "android-ndk-r11c-linux-x86_64.zip" ] || wget https://dl.google.com/android/repository/android-ndk-r11c-linux-x86_64.zip
	unzip -qo android-ndk-r11c-linux-x86_64.zip
fi

# fetch all sourcecode archive
[ -f "$libnl_tgz" ] || wget $libnl_url
[ -f "$iw_txz" ]    || wget "$iw_url"

for i in $input; do
	case $i in
	  arm64) i=aarch64; export ARCH="aarch64-linux-android"; export FOL=$ARCH; export SYSROOT="$NDK/platforms/android-21/arch-arm64";;
		arm) export ARCH="arm-linux-androideabi"; export FOL=$ARCH; export SYSROOT="$NDK/platforms/android-21/arch-arm";;
		x86) export ARCH="i686-linux-android"; export FOL=$i; export SYSROOT="$NDK/platforms/android-21/arch-x86";;
		x64) i=x86_64; export ARCH="x86_64-linux-android"; export FOL=$i; export SYSROOT="$NDK/platforms/android-21/arch-x86_64";;
		*) echo "Invalid arch $i!"; exit 1;;
	esac

	# output directory
	prefix="`pwd`/prefix-$i"
	[ -d "$prefix" ]    || mkdir $prefix

	# cleanup
	rm -rf $libnl_dir $iw_dir
	tar xf "${libnl_tgz}"

	# build libnl
	if ! [ -f "$prefix/lib/libnl-3.a" ] ; then
			(
		 tar xf "${libnl_tgz}"
		cd "$libnl_dir"
		../build_env.sh ./configure \
			--host=$i-linux-android \
			--enable-static --disable-shared \
			--disable-pthreads --disable-cli \
			--prefix=$prefix
		../build_env.sh make
		../build_env.sh make install
			)
	fi

	if ! [ -f "$prefix/bin/iw" ] ; then
			(
		tar xf "${iw_txz}"
		cd "$iw_dir"
		if ! [ -f ".patch.applied" ] ; then
			patch <../diff_iw41_Makefile_libm.patch
			touch ".patch.applied"
		fi
		export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig"
		../build_env.sh make V=1
		cp iw iw.stripped
		../build_env.sh sh -c "\${CROSS_COMPILE}strip -s iw.stripped"
		mkdir $prefix/bin
		cp -f iw iw.stripped $prefix/bin/
			)
	fi

	cd "$dir"

	echo "*** Iw has been compiled, output files are iw and iw.stripped in $prefix/bin"
done