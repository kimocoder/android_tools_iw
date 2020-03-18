## android_tools_iw

Latest 'iw' tool v5.4 for Android.
This tool downloads and compiles the binary with Netlink by the use of Android NDK.


### Get started compiling / installing

1. Download the NDK 11c toolchain (tested working)
2. Edit the "build_env.sh" to fit your setup/folder for toolchain.
   - Also edit if you wan't the ARM32 (32 bit) or ARM64 (64 bit) support.

3. Then simply use "make build" for compiling the binaries, "make install" for pushing it
   and setting up permissions through ADB on device. Then "make clean" is also available.




