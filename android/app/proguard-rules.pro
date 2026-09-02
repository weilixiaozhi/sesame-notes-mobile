-keep class com.sesame.notes.MainActivity { *; }

# 保留系统通过清单实例化的广播接收器
-keep public class * extends android.content.BroadcastReceiver

# 保留应用广播接收方法
-keepclassmembers class com.sesame.notes.** {
    public void onReceive(android.content.Context, android.content.Intent);
}

# 保留 Flutter 通知插件类
-keep class io.flutter.** { *; }
-keep class com.dexterous.** { *; }

# 保留本地通知插件类
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin { *; }

# 保留通知插件方法签名与泛型信息
-keepclassmembers class com.dexterous.flutterlocalnotifications.** {
    public *;
}

# 保留插件反射需要的类型元数据
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# 保留通知调度使用的时区数据
-keep class net.danlew.android.joda.** { *; }

# 保留通知插件通过反射读取的枚举
-keep class * extends java.lang.Enum { *; }

# 保留通知渠道相关类
-keep class android.app.NotificationChannel { *; }
-keep class android.app.NotificationManager { *; }
-keep class androidx.core.app.NotificationCompat** { *; }

# 保留平台通道相关类
-keep class io.flutter.plugin.common.** { *; }

# 保留 Android 系统 XML 接口及解析实现
-keep class android.content.res.XmlBlock { *; }
-keep class android.content.res.XmlBlock$Parser { *; }
-keep interface android.content.res.XmlResourceParser { *; }
-keep interface org.xmlpull.v1.XmlPullParser { *; }

-keep class org.xmlpull.v1.** { *; }
-dontwarn org.xmlpull.v1.**

# 保留运行时读取的注解信息
-keepattributes *Annotation*

# 保留 Android 系统 XML 接口
-keep interface android.content.res.** { *; }
-keep class android.content.res.** { *; }

# 保留崩溃诊断所需的源码与行号
-keepattributes SourceFile,LineNumberTable

# 保留系统通过清单实例化的应用组件
-keep public class * extends android.app.Application
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Service

# 直发 APK 不包含 Google Play Core
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# 直发 APK 不使用 Flutter Play 动态组件
-dontwarn io.flutter.app.FlutterPlayStoreSplitApplication
-dontwarn io.flutter.embedding.engine.deferredcomponents.PlayStoreDeferredComponentManager**
