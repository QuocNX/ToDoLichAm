# Flutter Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Gson
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }
-keep class sun.misc.Unsafe { *; }
-keep class com.google.gson.stream.** { *; }

# Prevent R8 from stripping the generic type information
-keepattributes EnclosingMethod
-keepattributes InnerClasses
