
# Release Procedure

0. Ensure that flow.gradle is building for release

1. Make a new change log

2. Update build number:
    * project.flow
    * Analytics.hx
    * Android Studio: Version number
    * Android Studio: Build number
    * Xcode: Version number

3. Commit and push

4. Run `fastlane android deploy`

5. Run `fastlane ios deploy`

6. Run `./push_to_itch.sh`
