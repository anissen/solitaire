# build for web
rm -rf bin/web
rm -rf bin/web.build
flow build web
butler push bin/web anissen/solitaire:web

# build for mac
rm -rf bin/mac64
rm -rf bin/mac64.build
flow build mac
butler push bin/mac64 anissen/solitaire:mac

# build for android
# cd android.project
# ./gradlew assembleRelease
# mkdir release-build
# rm release-build/*
# cp app/build/outputs/apk/app-release-unsigned.apk release-build/app-release-unsigned.apk
# cd ..
# butler push android.project/release-build anissen/solitaire:android