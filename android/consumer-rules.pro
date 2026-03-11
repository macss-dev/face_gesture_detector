# face_gesture_detector — ProGuard/R8 consumer rules
# These rules are automatically applied to any app that depends on this plugin.

# Disable R8 optimization — class merging breaks MediaPipe's
# stack-based native library loader (Graph.<clinit> uses stack inspection)
-dontoptimize

# Keep MediaPipe classes (JNI, reflection, protobuf-lite)
-keep class com.google.mediapipe.** { *; }
-keepclassmembers class com.google.mediapipe.** { *; }
-dontwarn com.google.mediapipe.**

# MediaPipe depends on protobuf-lite
-keep class com.google.protobuf.** { *; }
-dontwarn com.google.protobuf.**

# Keep plugin classes (EventChannel, MethodChannel handlers)
-keep class dev.macss.face_gesture_detector.** { *; }

# AutoValue annotation-processing classes (compile-time only, not needed at runtime)
-dontwarn javax.annotation.processing.**
-dontwarn javax.lang.model.**
-dontwarn autovalue.shaded.**
-dontwarn com.google.auto.**
