This guide shows you how to set up and build a raylib project for Android on Linux. This was tested on __*Ubuntu 21.10*__ (64-bit only) and Android 10. Generated APK files will run on Android 6 and up.

This guide is based on [gxbuild](https://github.com/gtrxAC/gxbuild), a simple shell script based build system that can build for Windows, Linux, Web and Android.

# Setup

## Directory setup
First, we need to create some directories for files used in the build process. Open a terminal in your project folder, this terminal will be needed throughout the guide. Run the following commands:
```sh
mkdir --parents android/sdk android/build assets include lib/armeabi-v7a lib/arm64-v8a lib/x86 lib/x86_64 src
cd android/build
mkdir --parents obj dex res/values src/com/raylib/game assets
mkdir --parents lib/armeabi-v7a lib/arm64-v8a lib/x86 lib/x86_64
mkdir --parents res/drawable-ldpi res/drawable-mdpi res/drawable-hdpi res/drawable-xhdpi
cd ../..
```

* `android` contains everything used by the Android build system.
* `android/ndk` contains the Android NDK.
* `android/sdk` contains the SDK and all of its packages.
* `android/build` contains temporary files used for the build, these will be packaged into the APK file.
* `assets` is used for your app icon and any other assets your project may need.
* `include` only has `raylib.h` by default but you can put headers for other libraries if needed.
* `lib` contains the compiled raylib library for Android.
* `src` is for your app's source code, put all `*.c` files there.

## Java
Android is based on the Java language, a Java installation is also required to create Android apps. There are many versions of Java, I use OpenJDK version 18 (or newer) which can be downloaded [here](https://openjdk.java.net/).

## Android SDK
The Android SDK (Software Development Kit) lets you create apps for Android. It has a modular design. The [Android Studio](https://developer.android.com/studio/) contains all of the packages, but in this guide we'll use the command line tools to install only the necessary packages. You can get the command line tools [here](https://developer.android.com/studio/#command-tools).

1. Decompress downloaded `commandlinetools-linux-...` into your project in `android/sdk`. Make sure there is a `cmdline-tools` folder.
2. From the terminal, run the following commands:

```sh
cd android/sdk/cmdline-tools/bin
./sdkmanager --update --sdk_root=../..
./sdkmanager --install "build-tools;29.0.3" --sdk_root=../..
./sdkmanager --install "platform-tools" --sdk_root=../..
./sdkmanager --install "platforms;android-29" --sdk_root=../..
cd ../../../..
```

## Android NDK
The Android NDK (Native Development Kit) allows Android apps to use the C programming language. Download it [here](https://developer.android.com/ndk/downloads/) and extract it. Rename the created `android-ndk-r...` folder to `ndk` and put it inside the `android` folder. Make sure there are `build`, `meta`, etc. folders inside `android/ndk`.

## Compile raylib
If you don't already have `raylib` in your project folder, clone the repository.
```sh
git clone https://github.com/raysan5/raylib --depth 1
```
Build raylib for ARM and x86 architectures, both 32 and 64 bit. You can exclude some of these if you know what you're doing. Make sure you don't see any errors and that the file sizes in `lib` make sense for each architecture.
```sh
cd raylib/src
cp raylib.h ../../include
make clean
make PLATFORM=PLATFORM_ANDROID ANDROID_NDK=../../android/ndk ANDROID_ARCH=arm ANDROID_API_VERSION=34
mv libraylib.a ../../lib/armeabi-v7a
make clean
make PLATFORM=PLATFORM_ANDROID ANDROID_NDK=../../android/ndk ANDROID_ARCH=arm64 ANDROID_API_VERSION=34
mv libraylib.a ../../lib/arm64-v8a
make clean
make PLATFORM=PLATFORM_ANDROID ANDROID_NDK=../../android/ndk ANDROID_ARCH=x86 ANDROID_API_VERSION=34
mv libraylib.a ../../lib/x86
make clean
make PLATFORM=PLATFORM_ANDROID ANDROID_NDK=../../android/ndk ANDROID_ARCH=x86_64 ANDROID_API_VERSION=34
mv libraylib.a ../../lib/x86_64
make clean
cd ../..
```

## Prepare project
A few more files need to be created for the Android build to work.

1. Create icons for different display densities (ldpi, mdpi, hdpi, xhdpi). In this guide, I will put them in `assets`, named `icon_ldpi.png`, `icon_mdpi.png` and so on. There are higher display densities but icons for them are not needed. As an example, these commands create the icons for the raylib logo:
```sh
cp raylib/logo/raylib_36x36.png assets/icon_ldpi.png
cp raylib/logo/raylib_48x48.png assets/icon_mdpi.png
cp raylib/logo/raylib_72x72.png assets/icon_hdpi.png
cp raylib/logo/raylib_96x96.png assets/icon_xhdpi.png
```

2. Keystore, this file contains the key for signing your APK file. You can change the `storepass` and `keypass` if you want to, but make sure to change them in the build script later.
```sh
cd android
keytool -genkeypair -validity 1000 -dname "CN=raylib,O=Android,C=ES" -keystore raylib.keystore -storepass 'raylib' -keypass 'raylib' -alias projectKey -keyalg RSA
cd ..
```

3. We still need a tiny bit of Java code to launch our app, this is handled by the NativeLoader class. Save this file in `android/build/src/com/raylib/game/NativeLoader.java`.
```java
package com.raylib.game;
public class NativeLoader extends android.app.NativeActivity {
    static {
        System.loadLibrary("main");
    }
}
```

4. The last file is our manifest, this file contains metadata about the app such as name and version. Save this in `android/build/AndroidManifest.xml`. There are a few things you can change here:
* `android:label="Game"` This will be the app name in the launcher (home screen).
* `android:versionCode="1"` Internal version code, this is not seen by the user.
* `android:versionName="1.0"` Human readable version number.
* `android:screenOrientation="landscape"` You can change this to `portrait` if needed.

```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
        package="com.raylib.game"
        android:versionCode="1" android:versionName="1.0" >
    <uses-sdk android:minSdkVersion="23" android:targetSdkVersion="34"/>
    <uses-feature android:glEsVersion="0x00020000" android:required="true"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
    <application android:allowBackup="false" android:label="Game" android:icon="@drawable/icon">
        <activity android:name="com.raylib.game.NativeLoader"
            android:theme="@android:style/Theme.NoTitleBar.Fullscreen"
            android:configChanges="orientation|keyboardHidden|screenSize"
            android:exported="true"
            android:screenOrientation="landscape" android:launchMode="singleTask"
            android:clearTaskOnLaunch="true">
            <meta-data android:name="android.app.lib_name" android:value="main"/>
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
    </application> 
</manifest>
```

# Build
Okay, finally we can build our APK file. You can create a shell script to build your project faster. Name it for example `build.sh` or `build_android.sh` in your project folder.
```sh
#!/bin/sh
# ______________________________________________________________________________
#
#  Compile raylib project for Android
# ______________________________________________________________________________

# stop on error and display each command as it gets executed. Optional step but helpful in catching where errors happen if they do.
set -xe

# NOTE: If you excluded any ABIs in the previous steps, remove them from this list too
ABIS="arm64-v8a armeabi-v7a x86 x86_64"

BUILD_TOOLS=android/sdk/build-tools/29.0.3
TOOLCHAIN=android/ndk/toolchains/llvm/prebuilt/linux-x86_64
NATIVE_APP_GLUE=android/ndk/sources/android/native_app_glue

FLAGS="-ffunction-sections -funwind-tables -fstack-protector-strong -fPIC -Wall \
	-Wformat -Werror=format-security -no-canonical-prefixes \
	-DANDROID -DPLATFORM_ANDROID -D__ANDROID_API__=29"

INCLUDES="-I. -Iinclude -I../include -I$NATIVE_APP_GLUE -I$TOOLCHAIN/sysroot/usr/include"

# Copy icons
cp assets/icon_ldpi.png android/build/res/drawable-ldpi/icon.png
cp assets/icon_mdpi.png android/build/res/drawable-mdpi/icon.png
cp assets/icon_hdpi.png android/build/res/drawable-hdpi/icon.png
cp assets/icon_xhdpi.png android/build/res/drawable-xhdpi/icon.png

# Copy other assets
cp assets/* android/build/assets

# ______________________________________________________________________________
#
#  Compile
# ______________________________________________________________________________
#
for ABI in $ABIS; do
	case "$ABI" in
		"armeabi-v7a")
			CCTYPE="armv7a-linux-androideabi"
			ARCH="arm"
			LIBPATH="arm-linux-androideabi"
			ABI_FLAGS="-std=c99 -march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3-d16"
			;;

		"arm64-v8a")
			CCTYPE="aarch64-linux-android"
			ARCH="aarch64"
			LIBPATH="aarch64-linux-android"
			ABI_FLAGS="-std=c99 -target aarch64 -mfix-cortex-a53-835769"
			;;

		"x86")
			CCTYPE="i686-linux-android"
			ARCH="i386"
			LIBPATH="i686-linux-android"
			ABI_FLAGS=""
			;;

		"x86_64")
			CCTYPE="x86_64-linux-android"
			ARCH="x86_64"
			LIBPATH="x86_64-linux-android"
			ABI_FLAGS=""
			;;
	esac
	CC="$TOOLCHAIN/bin/${CCTYPE}29-clang"

	# Compile native app glue
	# .c -> .o
	$CC -c $NATIVE_APP_GLUE/android_native_app_glue.c -o $NATIVE_APP_GLUE/native_app_glue.o \
		$INCLUDES -I$TOOLCHAIN/sysroot/usr/include/$CCTYPE $FLAGS $ABI_FLAGS

	# .o -> .a
	$TOOLCHAIN/bin/llvm-ar rcs lib/$ABI/libnative_app_glue.a $NATIVE_APP_GLUE/native_app_glue.o

	# Compile project
	for file in src/*.c; do
		$CC -c $file -o "$file".o \
			$INCLUDES -I$TOOLCHAIN/sysroot/usr/include/$CCTYPE $FLAGS $ABI_FLAGS
	done

        # Link the project with toolchain specific linker to avoid relocations issue.
	$TOOLCHAIN/bin/ld.lld src/*.o -o android/build/lib/$ABI/libmain.so -shared \
		--exclude-libs libatomic.a --build-id \
		-z noexecstack -z relro -z now \
		--warn-shared-textrel --fatal-warnings -u ANativeActivity_onCreate \
		-L$TOOLCHAIN/sysroot/usr/lib/$LIBPATH/29 \
		-L$TOOLCHAIN/lib/clang/17/lib/linux/$ARCH \
		-L. -Landroid/build/obj -Llib/$ABI \
		-lraylib -lnative_app_glue -llog -landroid -lEGL -lGLESv2 -lOpenSLES -latomic -lc -lm -ldl
done

# ______________________________________________________________________________
#
#  Build APK
# ______________________________________________________________________________
#
$BUILD_TOOLS/aapt package -f -m \
	-S android/build/res -J android/build/src -M android/build/AndroidManifest.xml \
	-I android/sdk/platforms/android-29/android.jar

# Compile NativeLoader.java
javac -verbose -source 1.8 -target 1.8 -d android/build/obj \
	-bootclasspath jre/lib/rt.jar \
	-classpath android/sdk/platforms/android-29/android.jar:android/build/obj \
	-sourcepath src android/build/src/com/raylib/game/R.java \
	android/build/src/com/raylib/game/NativeLoader.java

$BUILD_TOOLS/dx --verbose --dex --output=android/build/dex/classes.dex android/build/obj

# Add resources and assets to APK
$BUILD_TOOLS/aapt package -f \
	-M android/build/AndroidManifest.xml -S android/build/res -A assets \
	-I android/sdk/platforms/android-29/android.jar -F game.apk android/build/dex

# Add libraries to APK
cd android/build
for ABI in $ABIS; do
	../../$BUILD_TOOLS/aapt add ../../game.apk lib/$ABI/libmain.so
done
cd ../..

# Zipalign APK and sign
# NOTE: If you changed the storepass and keypass in the setup process, change them here too
$BUILD_TOOLS/zipalign -f 4 game.apk game.final.apk
mv -f game.final.apk game.apk

# Install apksigner with `sudo apt install apksigner`
apksigner sign  --ks android/raylib.keystore --out my-app-release.apk --ks-pass pass:raylib game.apk
mv my-app-release.apk game.apk

# Install to device or emulator
android/sdk/platform-tools/adb install -r game.apk
```

# Improvements
raylib android support could still be improved, there are a few issues:

## File system
Currently the file system is not accessible on Android. Trying to load any file outside the assets folder results in `Failed to open file`. This means that any user created files cannot be loaded.

Assets such as images and sounds that are bundled into the APK file can still be loaded. This build system automatically bundles everything in the `assets` folder into the APK.

## Assets folder
On Android, the default working directory for loading assets is the `assets` folder. On other platforms, it is usually the directory containing the executable. To make sure your assets are loaded from the same directory on all platforms, you can do this:

```c
#ifndef PLATFORM_ANDROID
	ChangeDirectory("assets");
#endif

myTexture = LoadTexture("texture.png");
mySound = LoadSound("sound.wav");
myFont = LoadFont("font.ttf");

#ifndef PLATFORM_ANDROID
	ChangeDirectory("..");
#endif
```
