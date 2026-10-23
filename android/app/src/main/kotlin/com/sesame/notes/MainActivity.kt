package com.sesame.notes

import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.content.BroadcastReceiver
import android.content.IntentFilter
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import android.util.Log
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/** 承载 Flutter 页面，并提供系统设置、提醒和更新通道。 */
class MainActivity : FlutterFragmentActivity() {
    private val notificationChannel = "notification_channel"
    private var networkChannel: EventChannel? = null
    private var networkCallback: ConnectivityManager.NetworkCallback? = null
    private var networkSink: EventChannel.EventSink? = null
    private var clockChannel: EventChannel? = null
    private var clockReceiver: BroadcastReceiver? = null
    private var deviceMetadataChannel: MethodChannel? = null
    private var memoNameOrderChannel: MethodChannel? = null

    /** 注册 Flutter 需要的原生通道。 */
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        memoNameOrderChannel = MemoNameOrder.register(flutterEngine.dartExecutor.binaryMessenger)
        deviceMetadataChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.sesame_notes.device_metadata"
        ).also { channel ->
            channel.setMethodCallHandler { call, result ->
                if (call.method != "readDeviceMetadata") {
                    result.notImplemented()
                } else {
                    try {
                        result.success(readDeviceMetadata())
                    } catch (error: Exception) {
                        Log.e("MainActivity", "设备系统资料读取失败", error)
                        result.error("DEVICE_METADATA_FAILED", "设备资料暂时无法读取，登录仍可继续", null)
                    }
                }
            }
        }
        stopRestAlertFromLaunch(intent)
        AppUpdateInstaller.register(
            this,
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.sesame_notes.update")
        )

        clockChannel = EventChannel(flutterEngine.dartExecutor.binaryMessenger, "com.sesame_notes.clock").also {
            it.setStreamHandler(object : EventChannel.StreamHandler {
                /** 仅发送时钟变化信号，日期由 Flutter 重新读取。 */
                override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                    stopClockMonitoring()
                    try {
                        val receiver = object : BroadcastReceiver() {
                            /** 系统日期、时间或时区改变时通知前台。 */
                            override fun onReceive(context: Context?, intent: Intent?) {
                                events.success("clockChanged")
                            }
                        }
                        val filter = IntentFilter().apply {
                            addAction(Intent.ACTION_DATE_CHANGED)
                            addAction(Intent.ACTION_TIME_CHANGED)
                            addAction(Intent.ACTION_TIMEZONE_CHANGED)
                        }
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            registerReceiver(receiver, filter, Context.RECEIVER_NOT_EXPORTED)
                        } else {
                            registerReceiver(receiver, filter)
                        }
                        clockReceiver = receiver
                    } catch (error: Exception) {
                        Log.e("MainActivity", "系统时间监听启动失败", error)
                        events.error("CLOCK_FAILED", "系统时间通知暂不可用", null)
                    }
                }

                /** 停止订阅时释放广播接收器。 */
                override fun onCancel(arguments: Any?) = stopClockMonitoring()
            })
        }

        networkChannel = EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.sesame_notes.network"
        ).also { channel ->
            channel.setStreamHandler(object : EventChannel.StreamHandler {
                /** 发送当前接口状态，并订阅默认网络变化。 */
                override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                    stopNetworkMonitoring()
                    networkSink = events
                    try {
                        val manager = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
                        val callback = object : ConnectivityManager.NetworkCallback() {
                            /** 默认网络出现后重新读取可用接口。 */
                            override fun onAvailable(network: Network) = publishNetworkState(this)

                            /** 接口能力变化不直接代表目标服务器可访问。 */
                            override fun onCapabilitiesChanged(network: Network, capabilities: NetworkCapabilities) =
                                publishNetworkState(this)

                            /** 默认网络丢失时同时检查是否已切换到其他接口。 */
                            override fun onLost(network: Network) = publishNetworkState(this)
                        }
                        networkCallback = callback
                        manager.registerDefaultNetworkCallback(callback)
                        publishNetworkState(callback)
                    } catch (error: Exception) {
                        Log.e("MainActivity", "网络监听启动失败", error)
                        events.error("NETWORK_STATUS_FAILED", "暂时无法读取网络状态", null)
                        stopNetworkMonitoring()
                    }
                }

                /** Flutter 停止订阅时释放系统回调。 */
                override fun onCancel(arguments: Any?) = stopNetworkMonitoring()
            })
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            notificationChannel
        ).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "scheduleReminderAlarm" -> {
                        result.success(ReminderAlarm.schedule(this, requireNotNull(call.arguments<Map<String, Any?>>())))
                    }
                    "cancelReminderAlarm" -> {
                        ReminderAlarm.cancel(this, requireNotNull(call.argument<Int>("id")))
                        result.success(null)
                    }
                    "cancelAllReminderAlarms" -> {
                        ReminderAlarm.cancelAll(this)
                        result.success(null)
                    }
                    "getPendingReminderAlarms" -> result.success(ReminderAlarm.pending(this))
                    "scheduleFitnessRestAlarm" -> {
                        FitnessRestAlarm.schedule(this, requireNotNull(call.argument<Int>("id")),
                            requireNotNull(call.argument<String>("title")), requireNotNull(call.argument<String>("body")),
                            requireNotNull(call.argument<Number>("at")).toLong())
                        result.success(null)
                    }
                    "cancelFitnessRestAlarm" -> {
                        FitnessRestAlarm.cancel(this, requireNotNull(call.argument<Int>("id")))
                        result.success(null)
                    }
                    "getPendingFitnessRestAlarm" -> result.success(FitnessRestAlarm.pending(this))
                    "getTimeZone" -> result.success(java.util.TimeZone.getDefault().id)
                    "prepareFitnessRestChannel" -> {
                        FitnessRestNotificationChannel.prepare(
                            this,
                            requireNotNull(call.argument<String>("channelName")),
                            requireNotNull(call.argument<Boolean>("soundEnabled")),
                            requireNotNull(call.argument<Boolean>("vibrationEnabled"))
                        )
                        result.success(true)
                    }
                    "openAppSettings" -> {
                        openAppSettings()
                        result.success(true)
                    }
                    "openAutoStartSettings" -> result.success(AutoStartSettings.open(this))
                    "openAppNotificationSettings" -> {
                        openAppNotificationSettings()
                        result.success(true)
                    }
                    "getBatteryOptimizationInfo" ->
                        result.success(getBatteryOptimizationInfo())
                    "getNotificationChannelInfo" ->
                        result.success(getNotificationChannelInfo(requireNotNull(call.argument<String>("channelId"))))
                    else -> result.notImplemented()
                }
            } catch (error: Exception) {
                Log.e("MainActivity", "系统设置操作失败: ${call.method}", error)
                result.error("SYSTEM_SETTINGS_FAILED", "系统提醒操作失败，请稍后重试", null)
            }
        }
    }

    /** 热启动通知沿用现有导航，同时立即停止对应休息声振。 */
    override fun onNewIntent(intent: Intent) {
        stopRestAlertFromLaunch(intent)
        super.onNewIntent(intent)
    }

    /** 普通打开应用不终止提醒，只有携带当前提醒令牌的点击才停止。 */
    private fun stopRestAlertFromLaunch(intent: Intent?) {
        try {
            FitnessRestAlarm.stopFromLaunch(this, intent)
        } catch (error: Exception) {
            Log.e("MainActivity", "停止已点击的休息提醒失败", error)
        }
    }

    /** 在主线程读取最新默认接口，忽略已经取消的监听回调。 */
    private fun publishNetworkState(callback: ConnectivityManager.NetworkCallback) {
        runOnUiThread {
            if (networkCallback !== callback) return@runOnUiThread
            try {
                val manager = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
                val capabilities = manager.getNetworkCapabilities(manager.activeNetwork)
                networkSink?.success(capabilities?.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET) == true)
            } catch (error: Exception) {
                Log.e("MainActivity", "网络状态读取失败", error)
                networkSink?.error("NETWORK_STATUS_FAILED", "暂时无法读取网络状态", null)
            }
        }
    }

    /** 注销系统监听；先清空归属，防止排队中的回调继续通知 Flutter。 */
    private fun stopNetworkMonitoring() {
        val callback = networkCallback
        networkCallback = null
        networkSink = null
        if (callback == null) return
        try {
            val manager = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
            manager.unregisterNetworkCallback(callback)
        } catch (error: Exception) {
            Log.e("MainActivity", "网络监听释放失败", error)
        }
    }

    /** Flutter 引擎退出后不再保留系统监听和事件通道。 */
    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        deviceMetadataChannel?.setMethodCallHandler(null)
        deviceMetadataChannel = null
        memoNameOrderChannel?.setMethodCallHandler(null)
        memoNameOrderChannel = null
        stopClockMonitoring()
        clockChannel?.setStreamHandler(null)
        clockChannel = null
        stopNetworkMonitoring()
        networkChannel?.setStreamHandler(null)
        networkChannel = null
        super.cleanUpFlutterEngine(flutterEngine)
    }

    /** 系统型号为同机型共享值，仅读取型号和系统版本，不访问唯一硬件身份。 */
    private fun readDeviceMetadata(): Map<String, String> = mapOf(
        "platform" to "android",
        "device_model" to Build.MODEL,
        "os_version" to "Android ${Build.VERSION.RELEASE} (API ${Build.VERSION.SDK_INT})"
    )

    /** 重复释放安全，避免引擎退出后仍持有 Activity。 */
    private fun stopClockMonitoring() {
        val receiver = clockReceiver ?: return
        clockReceiver = null
        try {
            unregisterReceiver(receiver)
        } catch (error: Exception) {
            Log.e("MainActivity", "系统时间监听释放失败", error)
        }
    }

    /** 查询系统是否允许应用绕过电池优化。 */
    private fun isIgnoringBatteryOptimizations(): Boolean {
        val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        return powerManager.isIgnoringBatteryOptimizations(packageName)
    }

    /** 打开当前应用的系统设置页。 */
    private fun openAppSettings() {
        startActivity(
            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.parse("package:$packageName")
            }
        )
    }

    /** 返回当前应用的系统省电豁免状态。 */
    private fun getBatteryOptimizationInfo(): Map<String, Any> {
        return mapOf(
            "isIgnoring" to isIgnoringBatteryOptimizations()
        )
    }

    /** 打开当前应用的全部通知设置，系统不支持时进入应用详情。 */
    private fun openAppNotificationSettings() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            openAppSettings()
            return
        }
        try {
            startActivity(
                Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).apply {
                    putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
                }
            )
        } catch (error: Exception) {
            Log.e("MainActivity", "应用通知设置无法打开，尝试应用详情页", error)
            // 详情页仍无法打开时由方法通道返回错误，让 Flutter 显示失败提示。
            openAppSettings()
        }
    }

    /** 返回指定提醒渠道的系统配置，低版本沿用应用级通知权限。 */
    private fun getNotificationChannelInfo(channelId: String): Map<String, Any> {
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return mapOf(
                "isEnabled" to manager.areNotificationsEnabled(),
                "importance" to "default",
                "sound" to true,
                "vibration" to true,
                "legacyVersion" to true
            )
        }

        val channel = manager.getNotificationChannel(channelId)
            ?: return mapOf(
                "isEnabled" to false,
                "importance" to "none",
                "sound" to false,
                "vibration" to false,
                "channelExists" to false
            )
        val importance = when (channel.importance) {
            NotificationManager.IMPORTANCE_NONE -> "none"
            NotificationManager.IMPORTANCE_MIN -> "min"
            NotificationManager.IMPORTANCE_LOW -> "low"
            NotificationManager.IMPORTANCE_DEFAULT -> "default"
            NotificationManager.IMPORTANCE_HIGH -> "high"
            NotificationManager.IMPORTANCE_MAX -> "max"
            else -> "unknown"
        }
        return mapOf(
            "isEnabled" to (manager.areNotificationsEnabled() &&
                channel.importance != NotificationManager.IMPORTANCE_NONE),
            "importance" to importance,
            "sound" to (channel.sound != null),
            "vibration" to channel.shouldVibrate(),
            "bypassDnd" to channel.canBypassDnd(),
            "showBadge" to channel.canShowBadge(),
            "lightColor" to channel.lightColor,
            "lockscreenVisibility" to channel.lockscreenVisibility
        )
    }
}
