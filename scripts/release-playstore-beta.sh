#!/usr/bin/env bash
flutter channel stable
flutter upgrade
flutter pub get
cd android
bundle install
bundle update fastlane
echo $PLAYSTORE_DEPLOY_KEY >> keys.json
bundle exec fastlane set_build_code_beta
cd ..
flutter build appbundle --target-platform android-arm,android-arm64,android-x64
mkdir -p build/android
cp build/app/outputs/bundle/release/app-release.aab build/android/
cd android
bundle exec fastlane deploy_beta_test
cd ..