package com.sesame.notes

import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import android.util.Log
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/** 承载 Flutter 页面，并提供系统设置和原生日志桥接。 */
class MainActivity : FlutterFragmentActivity() {
    private val notificationChannel = "notification_channel"
    private val loggerChannel = "com.sesame_notes.logger"

    /** 注册 Flutter 需要的原生通道。 */
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        LoggerPlugin.setup(
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, loggerChannel)
        )

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            notificationChannel
        ).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "isIgnoringBatteryOptimizations" ->
                        result.success(isIgnoringBatteryOptimizations())
                    "openAppSettings" -> {
                        openAppSettings()
                        result.success(true)
                    }
                    "getBatteryOptimizationInfo" ->
                        result.success(getBatteryOptimizationInfo())
                    "openNotificationChannelSettings" -> {
                        openNotificationChannelSettings()
                        result.success(true)
                    }
                    "getNotificationChannelInfo" ->
                        result.success(getNotificationChannelInfo())
                    else -> result.notImplemented()
                }
            } catch (error: Exception) {
                Log.e("MainActivity", "系统设置操作失败: ${call.method}", error)
                result.error("SYSTEM_SETTINGS_FAILED", "无法打开系统设置，请稍后重试", null)
            }
        }
    }

    /** 查询系统是否允许应用绕过电池优化。 */
    private fun isIgnoringBatteryOptimizations(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return true
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

    /** 返回电池优化状态与设备信息，供提醒设置页诊断。 */
    private fun getBatteryOptimizationInfo(): Map<String, Any> {
        return mapOf(
            "isIgnoring" to isIgnoringBatteryOptimizations(),
            "manufacturer" to Build.MANUFACTURER,
            "model" to Build.MODEL,
            "androidVersion" to Build.VERSION.RELEASE
        )
    }

    /** 打开记账提醒渠道设置；旧系统统一回到应用设置页。 */
    private fun openNotificationChannelSettings() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            openAppSettings()
            return
        }
        startActivity(
            Intent(Settings.ACTION_CHANNEL_NOTIFICATION_SETTINGS).apply {
                putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
                putExtra(Settings.EXTRA_CHANNEL_ID, "accounting_reminder")
            }
        )
    }

    /** 返回记账提醒渠道的当前系统配置。 */
    private fun getNotificationChannelInfo(): Map<String, Any> {
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return mapOf(
                "isEnabled" to if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    manager.areNotificationsEnabled()
                } else {
                    true
                },
                "importance" to "default",
                "sound" to true,
                "vibration" to true,
                "legacyVersion" to true
            )
        }

        val channel = manager.getNotificationChannel("accounting_reminder")
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
            "isEnabled" to (channel.importance != NotificationManager.IMPORTANCE_NONE),
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
