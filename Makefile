

build:
	#source build_env.sh
	./build_all.sh
	#.compile


install:
	adb push build/iw "/sdcard/iw"
	adb push build/iw.stripped "/sdcard/iw.stripped"
	adb shell 'su -c "mount -o rw,remount /system"'
	adb shell 'su -c "cp /sdcard/iw /system/xbin/iw"'
	adb shell 'su -c "cp /sdcard/iw.stripped /system/xbin/iw.stripped"'
	adb shell 'su -c "chmod +x /system/xbin/iw"'
	adb shell 'su -c "chmod +x /system/xbin/iw.stripped"'

	echo "* Sucessfully pushed to Android device, open Terminal and enjoy the binary."


clean:
	rm -rf build/
	rm -rf iw-5.4/
	echo "* Cleaned out the directory, all fresh!"
