# Flutter 引擎按固定类名反射调用插件注册入口。
-keep class io.flutter.plugins.GeneratedPluginRegistrant {
    public static void registerWith(io.flutter.embedding.engine.FlutterEngine);
}

# 通知缓存由 Gson 反射读写字段，样式子类的简单类名和枚举名称属于历史格式。
# 只保护持久化模型、字段和构造器，普通插件实现继续接受 R8 裁剪与混淆。
-keep class com.dexterous.flutterlocalnotifications.models.** {
    <fields>;
    <init>(...);
}

# 泛型类型、内部类型关系和序列化注解用于通知历史数据反序列化。
-keepattributes Signature,InnerClasses,EnclosingMethod,*Annotation*

# 源文件与行号支持正式包崩溃定位。
-keepattributes SourceFile,LineNumberTable

# JNI 方法与 @Keep 入口由 Android 默认规则和 AndroidX 消费者规则保留。
# Android 清单中的组件及构造器由资源处理生成的 aapt 规则保留。

# 直发 APK 的 Flutter 引擎包含可选 Play 动态组件引用。
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.app.FlutterPlayStoreSplitApplication
-dontwarn io.flutter.embedding.engine.deferredcomponents.PlayStoreDeferredComponentManager**
