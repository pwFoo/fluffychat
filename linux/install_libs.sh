#!/bin/sh -e
cd "$(dirname "$0")"

git clone https://gitlab.com/famedly/libraries/olm.git
cd olm
cmake -DCMAKE_BUILD_TYPE=Release -DOLM_TESTS=OFF .
cmake --build .
cp -P libolm.so* ../../build/linux/release/bundle/lib
cd ..

git clone https://gitlab.com/famedly/libraries/native_imaging.git
cd native_imaging/ios/src
cmake -DCMAKE_BUILD_TYPE=Release -DSYSTEM_LIBJPEG=OFF .
cmake --build .
cp libImaging.so ../../../../build/linux/release/bundle/lib
cd ../../..
