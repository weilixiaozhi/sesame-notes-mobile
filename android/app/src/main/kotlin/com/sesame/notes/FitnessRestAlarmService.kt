@file:Suppress("DEPRECATION")

package com.sesame.notes

import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.media.AudioAttributes
import android.media.Ringtone
import android.media.RingtoneManager
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.PowerManager
import android.os.VibrationEffect
import android.os.Vibrator
import android.provider.Settings
import android.util.Log
import android.content.pm.ApplicationInfo
import java.io.File

/** 前台服务只在休息结束的一分钟声振期间存活，不依赖 Flutter 是否在前台。 */
class FitnessRestAlarmService : Service() {
    private val handler = Handler(Looper.getMainLooper())
    private var ringtone: Ringtone? = null
    private var vibrator: Vibrator? = null
    private var wakeLock: PowerManager.WakeLock? = null
    private var activeToken: String? = null
    private val finishAlert = Runnable { stopPlaybackAndKeepNotification() }

    /** 非绑定服务，计时广播是唯一启动入口。 */
    override fun onBind(intent: Intent?): IBinder? = null

    /** 通知先进入前台，再按系统渠道实际选择播放声音和振动。 */
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        try {
            recordEvent("服务收到到期任务")
            val alarm = FitnessRestAlarm.due(this, intent?.getStringExtra(FitnessRestAlarm.TOKEN))
            if (alarm == null) {
                recordEvent("任务已失效或已投递，停止重复播放")
                if (activeToken == null) stopSelf(startId)
                return START_NOT_STICKY
            }
            releasePlayback()
            startForeground(FitnessRestAlarm.ID, FitnessRestAlarm.notification(this, alarm, true))
            activeToken = alarm.getString("token")
            FitnessRestAlarm.delivered(this, alarm)
            recordEvent("通知已投递，准备取得短时唤醒锁")
            // 短时持锁确保锁屏时也执行自动停止；超时与服务销毁提供双重释放。
            wakeLock = (getSystemService(POWER_SERVICE) as PowerManager)
                .newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "$packageName:rest-alert")
                .apply { acquire(RestAlarmPattern.ALERT_DURATION_MS + 2000) }
            handler.postDelayed(finishAlert, RestAlarmPattern.ALERT_DURATION_MS)
            recordEvent("自动停止已登记，开始读取声振设置")
            playAlert()
        } catch (error: Exception) {
            recordEvent("启动声振失败: ${error.stackTraceToString()}")
            Log.e("FitnessRestAlarm", "休息声振播放失败，停止播放并保留通知", error)
            try {
                // 服务建立前失败时仍交付普通通知；已投递的提醒不能再次响铃。
                FitnessRestAlarm.due(this, intent?.getStringExtra(FitnessRestAlarm.TOKEN))?.let {
                    FitnessRestAlarm.notifyFallback(this, it)
                }
            } catch (fallbackError: Exception) {
                Log.e("FitnessRestAlarm", "休息提醒降级投递失败", fallbackError)
            }
            stopPlaybackAndKeepNotification(startId)
        }
        return START_NOT_STICKY
    }

    /** 声音和振动各自读取系统开关；闹钟用途交给系统执行音量及勿扰限制。 */
    private fun playAlert() {
        val manager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        if (!manager.areNotificationsEnabled()) {
            recordEvent("应用通知权限关闭，跳过声振")
            return
        }
        val channel = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            manager.getNotificationChannel(FitnessRestNotificationChannel.ID) ?: run {
                recordEvent("休息通知渠道不存在，跳过声振")
                return
            }
        } else null
        recordEvent("声振渠道检查: importance=${channel?.importance}, vibration=${channel?.shouldVibrate()}, sound=${channel?.sound != null}")
        if (channel != null && channel.importance < NotificationManager.IMPORTANCE_DEFAULT) {
            recordEvent("休息渠道为静默级别，跳过声振")
            return
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P && channel?.group != null &&
            manager.getNotificationChannelGroup(channel.group)?.isBlocked == true) {
            recordEvent("休息渠道分组已关闭，跳过声振")
            return
        }
        val defaults = getSharedPreferences("fitness_rest_defaults", MODE_PRIVATE)
        val sound = if (channel != null) channel.sound else {
            if (defaults.getBoolean("sound", true)) Settings.System.DEFAULT_ALARM_ALERT_URI else null
        }
        val vibrate = channel?.shouldVibrate() ?: defaults.getBoolean("vibration", true)
        val attributes = AudioAttributes.Builder().setUsage(AudioAttributes.USAGE_ALARM)
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION).build()
        // 两项分别保护，铃声文件失效不能阻止振动，振动硬件异常不能中断铃声。
        if (sound != null) {
            try {
                ringtone = RingtoneManager.getRingtone(this, sound)?.apply {
                    audioAttributes = attributes
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) isLooping = true
                    play()
                    recordEvent("已提交闹钟铃声播放")
                }
            } catch (error: Exception) {
                Log.e("FitnessRestAlarm", "播放系统选择的闹钟铃声失败", error)
            }
        }
        if (vibrate) {
            try {
                vibrator = (getSystemService(VIBRATOR_SERVICE) as Vibrator).also { device ->
                    recordEvent("振动设备检查: available=${device.hasVibrator()}")
                    if (device.hasVibrator()) {
                        val pattern = channel?.vibrationPattern ?: longArrayOf(0, 1000, 300, 1000)
                        val bounded = RestAlarmPattern.forDuration(pattern, RestAlarmPattern.ALERT_DURATION_MS)
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            device.vibrate(VibrationEffect.createWaveform(bounded, -1), attributes)
                        } else {
                            @Suppress("DEPRECATION")
                            device.vibrate(bounded, -1, attributes)
                        }
                    }
                }
            } catch (error: Exception) {
                Log.e("FitnessRestAlarm", "播放休息闹钟振动失败", error)
            }
        }
    }

    /** 调试包保留有限的本地诊断，设备过滤日志时仍能核查执行阶段。 */
    private fun recordEvent(message: String) {
        Log.i("FitnessRestAlarm", message)
        if (applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE == 0) return
        try {
            val file = File(cacheDir, "rest_alarm_diagnostic.log")
            val entry = "${System.currentTimeMillis()} $message\n"
            if (file.length() > 65536) file.writeText(entry) else file.appendText(entry)
        } catch (error: Exception) {
            Log.e("FitnessRestAlarm", "记录休息声振诊断失败", error)
        }
    }

    /** 每项资源独立释放，单个系统接口失败也不能阻断其他资源清理。 */
    private fun releasePlayback() {
        handler.removeCallbacks(finishAlert)
        try { ringtone?.stop() } catch (error: Exception) { Log.e("FitnessRestAlarm", "停止铃声失败", error) }
        ringtone = null
        try { vibrator?.cancel() } catch (error: Exception) { Log.e("FitnessRestAlarm", "停止振动失败", error) }
        vibrator = null
        try { wakeLock?.let { if (it.isHeld) it.release() } } catch (error: Exception) { Log.e("FitnessRestAlarm", "释放休息唤醒锁失败", error) }
        wakeLock = null
    }

    /** 先解除通知与服务的绑定，再停止服务，避免系统销毁服务时清除已送达提醒。 */
    private fun stopPlaybackAndKeepNotification(startId: Int? = null) {
        try {
            releasePlayback()
            // 必须在停止服务之前解绑；收到销毁回调时系统已完成前台通知清理。
            stopForeground(STOP_FOREGROUND_DETACH)
            recordEvent("声振已停止，通知已独立保留")
        } catch (error: Exception) {
            Log.e("FitnessRestAlarm", "停止休息声振并保留通知失败", error)
        } finally {
            try {
                if (startId == null) stopSelf() else stopSelf(startId)
            } catch (error: Exception) {
                Log.e("FitnessRestAlarm", "停止休息闹钟服务失败", error)
            }
        }
    }

    /** 服务销毁时释放剩余声振资源，明确关闭提醒的入口自行清理通知。 */
    override fun onDestroy() {
        try {
            releasePlayback()
        } catch (error: Exception) {
            Log.e("FitnessRestAlarm", "结束休息闹钟服务失败", error)
        } finally {
            super.onDestroy()
        }
    }
}
