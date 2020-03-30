#!/bin/sh
set -e

libnl_tgz="libnl-3.2.25.tar.gz"
libnl_url="http://www.infradead.org/~tgr/libnl/files/$libnl_tgz"

iw_txz="iw-5.4.tar.xz"
iw_url="https://kernel.org/pub/software/network/iw/$iw_txz"

libnl_dir="${libnl_tgz%.tar.gz}"
iw_dir="${iw_txz%.tar.xz}"
prefix="`pwd`/prefix"

# fetch all sourcecode archive
[ -f "$libnl_tgz" ] || wget $libnl_url
[ -f "$iw_txz" ]    || wget "$iw_url"

# output directory
[ -d "$prefix" ]    || mkdir prefix

# unpack source files
[ -d "$libnl_dir" ] || tar xf "${libnl_tgz}"
[ -d "$iw_dir"    ] || tar xf "${iw_txz}"

# build libnl
if ! [ -f "${prefix}/lib/libnl-3.a" ] ; then
    (
	cd "$libnl_dir"
	../build_env.sh ./configure \
		--host=arm-linux-androideabi \
		--enable-static --disable-shared \
		--disable-pthreads --disable-cli \
		--prefix=$prefix
	../build_env.sh make
	../build_env.sh make install
    )
fi

if ! [ -f "${iw_dir}/iw" ] ; then
    (
	cd "$iw_dir"
	if ! [ -f ".patch.applied" ] ; then
		patch <../diff_iw41_Makefile_libm.patch
		touch ".patch.applied"
	fi
	export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig"
	../build_env.sh make V=1
	cp iw iw.stripped
	../build_env.sh sh -c "\${CROSS_COMPILE}strip -s iw.stripped"
    )
fi

echo "*** Iw has been compiled, output files are iw and iw.stripped in $iw_dir"
