# Framework for developing Android apps using the SDL
Developing Android apps using C (or C++) is a bit of a nightmare given the dependency landscape. This repo contains a working SDL-based example + a Dockerfile to get started.

## Workflow
1. Build the docker container (e.g. `docker build . -t android-dev` in the root directory)
2. Start the docker container and mount the `SDL_helloworld` folder (e.g. `docker run -v ./SDL_helloworld:/root/SDL_helloworld -it android-dev:latest /bin/bash`)
3. Source the necessary SDL3 and SDL3_image aar files and put them in `SDL_helloworld/android-project/app/libs` folder. These can be downloaded from the corresponding github release pages - any recent SDL3 version should work. Update the file names in the `app/build.gradle` file accordingly
4. Inside the container navigate to `SDL_helloworld/android-project` and run `./gradlew assemble`

The `android-project/app/build.gradle` is setup to run cmake in the `SDL_helloworld` folder to build the native code.

## TODO
* I'd like to avoid the manual aar release download step and instead build everything from source. I haven't figured out a way to produce the aar files yet, and just statically linking everything doesn't seem to work
* Figure out how APK signing works. So far I've just installed the `debug APK to my device for testing
