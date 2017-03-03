# build for web
flow build web
butler push bin/web anissen/solitaire:web

# build for mac
flow build mac
butler push bin/mac64 anissen/solitaire:mac

# build for android
cd android.project
./gradlew assembleRelease
mkdir release-build
rm release-build/*
cp app/build/outputs/apk/app-release-unsigned.apk release-build/app-release-unsigned.apk
cd ..
butler push android.project/release-build anissen/solitaire:android