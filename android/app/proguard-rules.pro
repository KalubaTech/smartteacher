# Keep Flutter classes
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep main activity
-keep class com.kalootech.smart_teacher.MainActivity { *; }

# Keep application class if you have a custom one
-keep class com.kalootech.smart_teacher.YourApplicationClass { *; }

# Prevent obfuscation of classes used in reflection
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keep class * extends java.lang.annotation.Annotation { *; }

# Gson, Retrofit, Moshi or other JSON libraries (if used)
-keep class com.google.gson.** { *; }
-keep class retrofit2.** { *; }
-dontwarn retrofit2.**
-keep class com.squareup.moshi.** { *; }

# Firebase (if used)
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Glide (if used)
-keep class com.bumptech.glide.** { *; }
-dontwarn com.bumptech.glide.**

# Kotlin metadata
-keep class kotlin.Metadata
-dontwarn kotlin.**

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep custom views or any class used by reflection
-keepclassmembers class * {
    public <init>(android.content.Context);
    public <init>(android.content.Context, android.util.AttributeSet);
    public <init>(android.content.Context, android.util.AttributeSet, int);
}

# Suppress warnings
-dontwarn okhttp3.**
-dontwarn okio.**

# Flutter WebView plugins (optional)
-keep class io.flutter.plugins.webviewflutter.** { *; }



# ============================================
# Added for Play Core and Deferred Components
# ============================================

# Play Core / Deferred Components
-keep class com.google.android.play.** { *; }
-dontwarn com.google.android.play.**

# Tasks used in deferred installs
-keep class com.google.android.play.core.tasks.** { *; }
-dontwarn com.google.android.play.core.tasks.**

# Flutter deferred component manager
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }
-dontwarn io.flutter.embedding.engine.deferredcomponents.**

# Jitsi Meet SDK
-keep class org.jitsi.meet.** { *; }
-keep interface org.jitsi.meet.** { *; }
-dontwarn org.jitsi.meet.**

# Keep WebRTC classes used internally by Jitsi
-keep class org.webrtc.** { *; }
-dontwarn org.webrtc.**

# React Native dependencies used internally by Jitsi
-keep class com.facebook.** { *; }
-dontwarn com.facebook.**

# Jitsi uses Java reflection for some dependencies (esp. JitsiMeetActivity)
-keepnames class * implements java.io.Serializable
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
-keepattributes *Annotation*,Signature,EnclosingMethod,InnerClasses

# Make sure your JitsiMeetActivity is preserved if used directly
-keep class org.jitsi.meet.sdk.JitsiMeetActivity { *; }

# Keep Parcelable implementations
-keep class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
}

# Keep Kotlin Parcelize
-keep class kotlinx.parcelize.Parcelize

# If using GIPHY SDK (as referenced in the error)
-keep class com.giphy.sdk.** { *; }
-dontwarn com.giphy.sdk.**
