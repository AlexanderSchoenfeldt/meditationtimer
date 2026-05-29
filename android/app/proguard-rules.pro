# Keep Flutter framework classes — required for release builds with R8.
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }

# just_audio uses ExoPlayer reflectively in spots.
-keep class com.google.android.exoplayer2.** { *; }
-dontwarn com.google.android.exoplayer2.**

# flutter_local_notifications uses GSON internally.
-keep class com.google.gson.** { *; }
-keep class com.dexterous.** { *; }
-dontwarn com.dexterous.**

# Keep our notification receivers/services discoverable.
-keep class de.unfoldhuman.intention.** { *; }

# We don't bundle Google Play Core (no deferred components). Flutter still
# references these classes for its play-store split-install path; tell R8
# they're optional.
-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**
