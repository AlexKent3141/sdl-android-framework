FROM ubuntu:24.04

RUN apt-get update && \
    apt-get install -y \
    build-essential \
    curl \
    cmake \
    zip \
    openjdk-21-jdk \
    ant \
    android-sdk-platform-tools-common \
    git \
    libsdl2-dev

# Install Android SDK
ENV ANDROID_HOME=/root
ENV ANDROID_SDK_PATH=/root
ENV ANDROID_SDK_ROOT=/root
ENV PATH=$PATH:$ANDROID_HOME/cmdline-tools:$ANDROID_HOME/cmdline-tools/bin:$ANDROID_HOME/platform-tools

RUN curl -L https://dl.google.com/android/repository/platform-tools-latest-linux.zip -o platform-tools.zip
RUN unzip platform-tools.zip -d $ANDROID_SDK_ROOT
RUN rm platform-tools.zip

RUN curl -L https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip -o cmdline-tools.zip
RUN unzip cmdline-tools.zip -d $ANDROID_SDK_ROOT
RUN rm cmdline-tools.zip

RUN mkdir ~/.android && touch ~/.android/repositories.cfg
RUN yes | sdkmanager --sdk_root=$ANDROID_SDK_ROOT "build-tools;29.0.2" "platforms;android-29"

# Install Android NDK
# download URL: https://developer.android.com/ndk/downloads
ENV ANDROID_NDK_PATH=/root/ndk-bundle
ENV ANDROID_NDK_ROOT=/root/ndk-bundle

RUN curl -L https://dl.google.com/android/repository/android-ndk-r27d-linux.zip -o androidndk.zip
RUN unzip androidndk.zip -d /root
RUN rm androidndk.zip
RUN mv /root/android-ndk* $ANDROID_NDK_ROOT

# SDL repo for the android-project build scripts
RUN curl -L https://github.com/libsdl-org/SDL/releases/download/release-2.32.10/SDL2-2.32.10.tar.gz -o SDL2-2.32.10.tar.gz
RUN tar -xf SDL2-2.32.10.tar.gz -C /root
RUN rm SDL2-2.32.10.tar.gz

WORKDIR /root/build
