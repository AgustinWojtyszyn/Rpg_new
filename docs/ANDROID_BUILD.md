# Android build

## Shipping target

The Play Store preset exports an Android App Bundle (AAB) through Gradle.

- Engine target: Godot 4.7.2
- ABI: arm64-v8a
- Target SDK: Android 16 / API 36
- Renderer: GL Compatibility
- Core game: offline-first, so INTERNET permission stays disabled until a network feature such as rewarded ads is deliberately integrated.

## Local prerequisites

Install the Android SDK/toolchain supported by Godot 4.7.2 and install Godot's Android build template before creating a release bundle.

## Signing

Release signing material is deliberately not stored in this repository.

Keep the release keystore, alias and passwords in local editor settings or CI secrets. Never commit:

- keystore / jks / p12 files;
- export_credentials.cfg;
- signing passwords.

## Export

Use the preset named **Android Play AAB**.

The preset's export format is AAB and its output path is:

    build/android/rpg_new.aab

The release version code must be increased for every bundle uploaded to Google Play.
