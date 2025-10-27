# Firebase / Play Services
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Protobuf (used by some Firebase libs)
-keep class com.google.protobuf.** { *; }
-dontwarn com.google.protobuf.**

# If you still have any old TFLite bits until you purge them:
# -keep class org.tensorflow.** { *; }
# -dontwarn org.tensorflow.**
# TensorFlow Lite
-keep class org.tensorflow.** { *; }
-dontwarn org.tensorflow.**

# FlatBuffers used by TFLite
-keep class com.google.flatbuffers.** { *; }
-dontwarn com.google.flatbuffers.**
