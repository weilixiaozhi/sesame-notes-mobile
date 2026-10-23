package com.sesame.notes

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.media.AudioAttributes
import android.os.Build
import android.provider.Settings
import android.util.Log

/** 休息提醒使用唯一系统渠道，声音和振动由系统设置统一管理。 */
internal object FitnessRestNotificationChannel {
    const val ID = "fitness_rest_alarm_v2"

    /** 按当前偏好首次创建渠道，已有渠道的用户开关与声振设置保持原值。 */
    fun prepare(context: Context, name: String, sound: Boolean, vibration: Boolean) {
        try {
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
                check(context.getSharedPreferences("fitness_rest_defaults", Context.MODE_PRIVATE).edit()
                    .putBoolean("sound", sound).putBoolean("vibration", vibration).commit())
                return
            }
            val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            if (manager.getNotificationChannel(ID) != null) return
            val channel = NotificationChannel(ID, name, NotificationManager.IMPORTANCE_HIGH)
            channel.vibrationPattern = longArrayOf(0, 1000, 300, 1000)
            channel.enableVibration(vibration)
            channel.setShowBadge(false)
            channel.setSound(
                if (sound) Settings.System.DEFAULT_ALARM_ALERT_URI else null,
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_ALARM)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build()
            )
            manager.createNotificationChannel(channel)
        } catch (error: Exception) {
            Log.e("FitnessRestNotification", "初始化休息通知渠道失败", error)
            throw error
        }
    }
}
