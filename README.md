# Intention

A minimal, **offline-only** meditation timer for Android.
No accounts, no cloud, no analytics. Your practice stays on your device.

## Features

- Quiet timer with optional interval bells
- Daily streak with gentle recovery if you miss a day
- Stats: totals, weekly bars, averages, longest streak
- Custom practice types you define yourself
- Three themes: light, dark, sepia
- Plain-text JSON export and import — your data is yours, in a format you can read

## Privacy

Intention stores everything in a single JSON file on your device.
There is no network access. There are no third-party SDKs.
The exported backup is the same file you can open in any text editor.

## Download the APK

APK builds are attached to the [GitHub Releases](../../releases) of this repo and
mirrored at [unfold-human.de](https://unfold-human.de).

On your phone: tap the `.apk` to install. Android will ask for permission to
install from an unknown source the first time — allow it for your browser, then
re-tap.

## Develop

```bash
flutter pub get
flutter run
```

Tests:

```bash
flutter test
```

Regenerate the bell tone or app icon (only needed when you change the source
tokens):

```bash
dart run tool/generate_bell.dart
dart run tool/generate_icon.dart
dart run flutter_launcher_icons
dart run flutter_native_splash:create --path=flutter_native_splash.yaml
```

## Release a signed APK

**One-time setup — generate a keystore:**

```bash
keytool -genkey -v \
  -keystore android/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias intention
```

Keep the resulting `upload-keystore.jks` and the password somewhere safe and
backed up. Losing them means you can never ship a signed update of this app
again — Android tracks signatures, not just package IDs.

**Local release build:**

1. Copy `android/key.properties.example` to `android/key.properties` and fill in
   the keystore password and key password you just set.
2. `flutter build apk --release`
3. The APK lands at `build/app/outputs/flutter-apk/app-release.apk`.

**GitHub Actions release** (`.github/workflows/release.yml`):

Add these repository secrets first:

- `ANDROID_KEYSTORE_BASE64` — `base64 -i android/upload-keystore.jks | pbcopy`
  on macOS, paste as the secret value
- `ANDROID_STORE_PASSWORD` — keystore password
- `ANDROID_KEY_ALIAS` — `intention` (or whatever you used)
- `ANDROID_KEY_PASSWORD` — key password (often the same as store password)

Then ship a release:

```bash
git tag v0.1.0
git push origin v0.1.0
```

The workflow runs analyzer + tests, decodes the keystore from secrets, builds
a release APK named `intention-v0.1.0.apk`, and attaches it to a GitHub Release.
Download from there, upload to `unfold-human.de`.

You can also trigger the workflow manually via the Actions tab — useful for a
dry-run without cutting a tag.

## License

[MIT](LICENSE)
