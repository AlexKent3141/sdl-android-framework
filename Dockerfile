FROM ubuntu:24.04

RUN apt-get update && \
    apt-get install -y \
    build-essential \
    vim \
    curl \
    wget \
    cmake \
    zip \
    git \
    openjdk-17-jdk

# Install Android SDK
# Required
ENV ANDROID_HOME=/root
ENV ANDROID_SDK_PATH=/root
ENV ANDROID_SDK_ROOT=/root
ENV PATH=$PATH:$ANDROID_HOME/cmdline-tools:$ANDROID_HOME/cmdline-tools/bin:$ANDROID_HOME/platform-tools

# RUN curl -L https://dl.google.com/android/repository/platform-tools-latest-linux.zip -o platform-tools.zip
# RUN unzip platform-tools.zip -d $ANDROID_SDK_ROOT
# RUN rm platform-tools.zip

# Required for SDK Manager
RUN curl -L https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip -o cmdline-tools.zip
RUN unzip cmdline-tools.zip -d $ANDROID_SDK_ROOT
RUN rm cmdline-tools.zip

RUN mkdir ~/.android && touch ~/.android/repositories.cfg
RUN yes | sdkmanager --sdk_root=$ANDROID_SDK_ROOT "build-tools;29.0.2" "platforms;android-29"

# Install Android NDK
# Not currently required: check later
# download URL: https://developer.android.com/ndk/downloads
# ENV ANDROID_NDK_PATH=/root/ndk-bundle
# ENV ANDROID_NDK_ROOT=/root/ndk-bundle
# ENV NDK_HOME=/root/ndk-bundle

# RUN curl -L https://dl.google.com/android/repository/android-ndk-r27d-linux.zip -o androidndk.zip
# RUN unzip androidndk.zip -d /root
# RUN rm androidndk.zip
# RUN mv /root/android-ndk* $ANDROID_NDK_ROOT

# TODO: download and install gradle from "https://services.gradle.org/distributions/gradle-8.6-bin.zip"

WORKDIR /root/build
