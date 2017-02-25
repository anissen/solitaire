# build for web
flow build web
butler push bin/web anissen/solitaire:web

# build for mac
flow build mac
butler push bin/mac64 anissen/solitaire:mac

# build for android
cd android.project && ./gradlew assembleRelease && cd ..
butler push android.project/app/build/outputs/apk/app-release-unsigned.apk anissen/solitaire:android