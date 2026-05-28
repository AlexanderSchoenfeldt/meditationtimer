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

## Download

APK builds will be available on [unfold-human.de](https://unfold-human.de) and from this repository's [Releases](../../releases).

## Develop

```bash
flutter pub get
flutter run
```

Tests:
```bash
flutter test
```

## License

[MIT](LICENSE)
