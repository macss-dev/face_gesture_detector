# Disable R8 optimization (class merging breaks MediaPipe's
# stack-based native library loader)
-dontoptimize

# Keep all MediaPipe classes (JNI, reflection, native library loading)
-keep class com.google.mediapipe.** { *; }
-keepclassmembers class com.google.mediapipe.** { *; }
-dontwarn com.google.mediapipe.**

# Keep protobuf (used by MediaPipe)
-keep class com.google.protobuf.** { *; }
-dontwarn com.google.protobuf.**

# Keep ALL google classes to prevent R8 class-merging that breaks
# MediaPipe's stack-based native library loader
-keep class com.google.** { *; }
-dontwarn com.google.**

# Keep plugin classes
-keep class dev.macss.face_gesture_detector.** { *; }

# AutoValue compile-time only
-dontwarn javax.annotation.processing.**
-dontwarn javax.lang.model.**
-dontwarn autovalue.shaded.**
-dontwarn com.google.auto.**
