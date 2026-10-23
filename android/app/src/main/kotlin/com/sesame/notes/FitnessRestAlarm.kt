package com.sesame.notes

import android.app.AlarmManager
import android.app.Notification
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.net.Uri
import android.util.Log
import androidx.core.app.NotificationCompat
import org.json.JSONObject
import java.util.UUID

/** 休息只保存一个带令牌的系统闹钟，旧广播不能唤起已经取消或替换的提醒。 */
internal object FitnessRestAlarm {
    const val ID = 2001
    const val FIRE = "com.sesame.notes.REST_ALARM"
    const val DISMISS = "com.sesame.notes.DISMISS_REST_ALARM"
    const val TOKEN = "restAlarmToken"
    private const val STORE = "fitness_rest_alarm"

    /** 使用应用私有存储跨进程保存到期时间及投递状态。 */
    private fun preferences(context: Context) = context.getSharedPreferences(STORE, Context.MODE_PRIVATE)

    /** 读取当前任务；缺失表示用户已经停止计时。 */
    fun read(context: Context): JSONObject? = preferences(context).getString("alarm", null)?.let(::JSONObject)

    /** 同步提交后再调用系统，防止进程退出造成闹钟与应用记录不一致。 */
    private fun save(context: Context, alarm: JSONObject?) {
        check(preferences(context).edit().putString("alarm", alarm?.toString()).commit()) {
            "无法保存休息闹钟"
        }
    }

    /** 待执行列表不包含已经投递的通知，也不补响过去的计时。 */
    fun pending(context: Context): Map<String, Any>? {
        val alarm = read(context) ?: return null
        if (alarm.optBoolean("delivered") || alarm.getLong("at") <= System.currentTimeMillis()) return null
        return mapOf("id" to ID, "title" to alarm.getString("title"), "body" to alarm.getString("body"))
    }

    /** 登记用户主动设置的休息倒计时，并在系统拒绝时恢复原任务记录。 */
    fun schedule(context: Context, id: Int, title: String, body: String, at: Long) {
        require(id == ID) { "休息闹钟编号不匹配" }
        if (at <= System.currentTimeMillis()) return
        val previous = read(context)
        val alarm = JSONObject().put("title", title).put("body", body).put("at", at)
            .put("token", UUID.randomUUID().toString()).put("delivered", false)
        try {
            save(context, alarm)
            register(context, alarm)
        } catch (error: Exception) {
            save(context, previous)
            discardOperation(context, alarm)
            Log.e("FitnessRestAlarm", "登记系统休息闹钟失败", error)
            throw error
        }
        // 新任务登记成功后才撤销旧任务；令牌也使已出队的旧广播无法误触发。
        if (previous != null) discardOperation(context, previous)
    }

    /** 优先采用闹钟模式；无精确权限时保留允许待机投递的普通通知。 */
    private fun register(context: Context, alarm: JSONObject) {
        val manager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val exact = Build.VERSION.SDK_INT < Build.VERSION_CODES.S || manager.canScheduleExactAlarms()
        val intent = Intent(context, FitnessRestAlarmReceiver::class.java).setAction(FIRE)
            .setData(operationUri(alarm))
            .putExtra(TOKEN, alarm.getString("token")).putExtra("exact", exact)
        val operation = PendingIntent.getBroadcast(context, ID, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        try {
            if (exact) {
                manager.setAlarmClock(AlarmManager.AlarmClockInfo(alarm.getLong("at"), openIntent(context, alarm)), operation)
            } else {
                manager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, alarm.getLong("at"), operation)
                Log.w("FitnessRestAlarm", "没有精确闹钟权限，休息提醒可能延迟并由系统通知播放声振")
            }
        } catch (error: SecurityException) {
            // 权限可能在读取与登记之间被撤回，重新使用非精确任务且不启动后台播放服务。
            if (!exact) throw error
            Log.w("FitnessRestAlarm", "精确闹钟权限已撤回，降级登记提醒", error)
            intent.putExtra("exact", false)
            val fallback = PendingIntent.getBroadcast(context, ID, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
            manager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, alarm.getLong("at"), fallback)
        }
    }

    /** 重启或更新后只恢复尚未到期的闹钟，不重放已经完成的提醒。 */
    fun restore(context: Context) {
        val alarm = read(context) ?: return
        if (!alarm.optBoolean("delivered") && alarm.getLong("at") > System.currentTimeMillis()) register(context, alarm)
    }

    /** 接收端必须校验令牌和状态，抵御取消、替换及重复广播。 */
    fun due(context: Context, token: String?): JSONObject? {
        val alarm = read(context) ?: return null
        return alarm.takeIf {
            token == it.getString("token") && !it.optBoolean("delivered") &&
                it.getLong("at") <= System.currentTimeMillis()
        }
    }

    /** 投递一次后保留状态，返回应用或重启不会再次响铃。 */
    fun delivered(context: Context, alarm: JSONObject) = save(context, alarm.put("delivered", true))

    /** 明确取消计时才能清理通知；令牌限制旧通知上的关闭操作。 */
    fun cancel(context: Context, id: Int = ID, token: String? = null) {
        require(id == ID) { "休息闹钟编号不匹配" }
        val alarm = read(context)
        if (token != null && alarm?.optString("token") != token) return
        save(context, null)
        if (alarm != null) discardOperation(context, alarm)
        context.stopService(Intent(context, FitnessRestAlarmService::class.java))
        (context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager).cancel(ID)
    }

    /** 每次登记使用独立身份，失败回滚不会改写旧 PendingIntent 的令牌。 */
    private fun operationUri(alarm: JSONObject): Uri = Uri.parse("sesame-rest://alarm/${alarm.getString("token")}")

    /** 记录已失效后尽力释放系统任务；清理失败也不能阻断正在播放的声振停止。 */
    private fun discardOperation(context: Context, alarm: JSONObject) {
        try {
            val operation = PendingIntent.getBroadcast(context, ID,
                Intent(context, FitnessRestAlarmReceiver::class.java).setAction(FIRE).setData(operationUri(alarm)),
                PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE)
            if (operation != null) {
                (context.getSystemService(Context.ALARM_SERVICE) as AlarmManager).cancel(operation)
                operation.cancel()
            }
        } catch (error: Exception) {
            Log.e("FitnessRestAlarm", "清理失效休息闹钟失败，后续广播将由令牌校验拦截", error)
        }
    }

    /** 点击已投递提醒时关闭声振和通知，保留已投递标志，导航继续交给通知插件。 */
    fun stopFromLaunch(context: Context, intent: Intent?) {
        val token = intent?.getStringExtra(TOKEN) ?: return
        val alarm = read(context) ?: return
        if (alarm.optString("token") == token && alarm.optBoolean("delivered")) {
            context.stopService(Intent(context, FitnessRestAlarmService::class.java))
            // 前台服务通知解绑后可能没有自动清除标记，点击时显式关闭当前已投递提醒。
            (context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager).cancel(ID)
        }
    }

    /** 使用现有通知点击协议，冷启动和热启动都经过应用解锁闸门。 */
    private fun openIntent(context: Context, alarm: JSONObject): PendingIntent = PendingIntent.getActivity(
        context, ID, Intent(context, MainActivity::class.java).setAction("SELECT_NOTIFICATION")
            .addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            .putExtra("notificationId", ID).putExtra("payload", "/fitness/workout")
            .putExtra(TOKEN, alarm.getString("token")),
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
    )

    /** 服务通知只负责展示；直接声振读取同一系统渠道，避免系统重复播放。 */
    fun notification(context: Context, alarm: JSONObject, silent: Boolean): Notification {
        val dismiss = PendingIntent.getBroadcast(context, ID,
            Intent(context, FitnessRestAlarmReceiver::class.java).setAction(DISMISS)
                .putExtra(TOKEN, alarm.getString("token")),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        val builder = NotificationCompat.Builder(context, FitnessRestNotificationChannel.ID)
            .setSmallIcon(context.applicationInfo.icon)
            .setContentTitle(alarm.getString("title")).setContentText(alarm.getString("body"))
            .setCategory(NotificationCompat.CATEGORY_ALARM).setPriority(NotificationCompat.PRIORITY_HIGH)
            .setVisibility(NotificationCompat.VISIBILITY_PRIVATE).setAutoCancel(true)
            .setContentIntent(openIntent(context, alarm)).setDeleteIntent(dismiss)
            .addAction(0, context.getString(android.R.string.cancel), dismiss)
            .setForegroundServiceBehavior(NotificationCompat.FOREGROUND_SERVICE_IMMEDIATE)
            .setSilent(silent)
        if (!silent && Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            val defaults = context.getSharedPreferences("fitness_rest_defaults", Context.MODE_PRIVATE)
            if (defaults.getBoolean("sound", true)) {
                @Suppress("DEPRECATION")
                builder.setSound(android.provider.Settings.System.DEFAULT_ALARM_ALERT_URI, android.media.AudioManager.STREAM_ALARM)
            }
            if (defaults.getBoolean("vibration", true)) builder.setVibrate(longArrayOf(0, 1000, 300, 1000))
        }
        return builder.build()
    }

    /** 后台播放不可用时仍交付通知，失败原因记录到原生日志。 */
    fun notifyFallback(context: Context, alarm: JSONObject) {
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.notify(ID, notification(context, alarm, false))
        delivered(context, alarm)
    }
}

/** 系统闹钟独立于 Flutter 页面生命周期执行。 */
class FitnessRestAlarmReceiver : BroadcastReceiver() {
    /** 只处理自有闹钟、用户关闭及系统恢复事件，所有错误均记录详细上下文。 */
    override fun onReceive(context: Context, intent: Intent) {
        try {
            when (intent.action) {
                FitnessRestAlarm.DISMISS -> FitnessRestAlarm.cancel(context, token = intent.getStringExtra(FitnessRestAlarm.TOKEN))
                FitnessRestAlarm.FIRE -> {
                    val alarm = FitnessRestAlarm.due(context, intent.getStringExtra(FitnessRestAlarm.TOKEN)) ?: return
                    if (!intent.getBooleanExtra("exact", false)) {
                        FitnessRestAlarm.notifyFallback(context, alarm)
                        return
                    }
                    try {
                        val service = Intent(context, FitnessRestAlarmService::class.java)
                            .putExtra(FitnessRestAlarm.TOKEN, alarm.getString("token"))
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) context.startForegroundService(service)
                        else context.startService(service)
                    } catch (error: Exception) {
                        Log.e("FitnessRestAlarm", "系统拒绝休息声振服务，保留普通通知", error)
                        FitnessRestAlarm.notifyFallback(context, alarm)
                    }
                }
                Intent.ACTION_BOOT_COMPLETED, Intent.ACTION_MY_PACKAGE_REPLACED -> FitnessRestAlarm.restore(context)
            }
        } catch (error: Exception) {
            Log.e("FitnessRestAlarm", "处理休息闹钟失败: ${intent.action}", error)
        }
    }
}
