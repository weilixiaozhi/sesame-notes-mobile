package com.sesame.notes

import android.app.AlarmManager
import android.app.Notification
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat
import org.json.JSONObject
import java.time.ZoneId
import java.util.UUID

/** 记账和纪念日由系统闹钟独立投递，每个业务编号持久化一个带令牌的任务。 */
internal object ReminderAlarm {
    private const val STORE = "reminder_alarms"
    private const val TAG = "ReminderAlarm"
    const val FIRE = "com.sesame.notes.REMINDER_ALARM"
    private const val TOKEN = "reminderAlarmToken"

    /** 应用私有状态跨进程保存，通知正文不会离开设备。 */
    private fun preferences(context: Context) = context.getSharedPreferences(STORE, Context.MODE_PRIVATE)

    /** 按业务编号读取当前版本，缺失表示任务已经被用户取消或完成。 */
    private fun read(context: Context, id: Int): JSONObject? =
        preferences(context).getString(id.toString(), null)?.let(::JSONObject)

    /** 同步保存保证系统唤醒接收器时能够验证当前令牌。 */
    private fun save(context: Context, id: Int, alarm: JSONObject?) {
        val editor = preferences(context).edit()
        if (alarm == null) editor.remove(id.toString()) else editor.putString(id.toString(), alarm.toString())
        check(editor.commit()) { "无法保存提醒任务: $id" }
    }

    /** 每个编号单独读取并记录损坏数据，单条异常不能阻断其他提醒。 */
    private fun alarms(context: Context): List<JSONObject> = preferences(context).all.keys.mapNotNull { key ->
        try {
            read(context, key.toInt())
        } catch (error: Exception) {
            Log.e(TAG, "读取提醒任务失败: id=$key", error)
            null
        }
    }

    /** 新任务确认登记后才释放旧版本，失败时恢复旧记录和旧系统任务。 */
    fun schedule(context: Context, arguments: Map<String, Any?>): String {
        val alarm = JSONObject(arguments)
        val id = alarm.getInt("id")
        require(id >= 0) { "提醒编号必须为非负整数" }
        require(alarm.getLong("at") > 0) { "提醒时间无效" }
        alarm.getJSONObject("platformSpecifics").getString("channelId")
        val previous = read(context, id)
        if (alarm.optBoolean("daily")) updateDailyTime(alarm, System.currentTimeMillis())
        else ZoneId.of(alarm.getString("timeZoneName"))
        return replace(context, alarm, previous)
    }

    /** 每日钟面时分来自用户偏好，时区与下一次触发时刻来自当前设备。 */
    private fun updateDailyTime(alarm: JSONObject, now: Long) {
        ZoneId.of(alarm.getString("timeZoneName"))
        val schedule = ReminderAlarmTime.nextDeviceDaily(alarm.getInt("hour"), alarm.getInt("minute"), now)
        alarm.put("timeZoneName", schedule.timeZoneName).put("at", schedule.at)
    }

    /** 新令牌成功登记后才释放旧任务，失败时保留旧记录和旧系统任务。 */
    private fun replace(context: Context, alarm: JSONObject, previous: JSONObject?): String {
        val id = alarm.getInt("id")
        alarm.put("token", UUID.randomUUID().toString()).put("delivered", false)
        val mode = try {
            save(context, id, alarm)
            register(context, alarm)
        } catch (error: Exception) {
            try {
                save(context, id, previous)
            } catch (rollbackError: Exception) {
                Log.e(TAG, "恢复原提醒记录失败: id=$id", rollbackError)
            }
            discard(context, alarm)
            Log.e(TAG, "登记提醒失败，保留原任务: id=$id", error)
            throw error
        }
        if (previous != null) discard(context, previous)
        return mode
    }

    /** 执行广播使用独立令牌身份，旧广播和回滚清理不能影响新任务。 */
    private fun fireIntent(context: Context, alarm: JSONObject) =
        Intent(context, ReminderAlarmReceiver::class.java).setAction(FIRE)
            .setData(Uri.parse("sesame-reminder://alarm/${alarm.getInt("id")}/${alarm.getString("token")}"))
            .putExtra("id", alarm.getInt("id")).putExtra(TOKEN, alarm.getString("token"))

    /** 系统下一闹钟入口和通知点击只打开页面，不触发提醒广播。 */
    private fun openIntent(context: Context, alarm: JSONObject): PendingIntent = PendingIntent.getActivity(
        context, alarm.getInt("id"), Intent(context, MainActivity::class.java).setAction("SELECT_NOTIFICATION")
            .addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            .putExtra("notificationId", alarm.getInt("id")).putExtra("payload", alarm.getString("payload")),
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
    )

    /** 有授权时使用用户可见闹钟模式，未授权时保留允许待机触发的普通提醒。 */
    private fun register(context: Context, alarm: JSONObject): String {
        val manager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val operation = PendingIntent.getBroadcast(context, alarm.getInt("id"), fireIntent(context, alarm),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        val exact = alarm.getJSONObject("platformSpecifics").getString("scheduleMode") == "alarmClock" &&
            (Build.VERSION.SDK_INT < Build.VERSION_CODES.S || manager.canScheduleExactAlarms())
        var mode = if (exact) "alarmClock" else "inexactAllowWhileIdle"
        try {
            if (exact) {
                manager.setAlarmClock(AlarmManager.AlarmClockInfo(alarm.getLong("at"), openIntent(context, alarm)), operation)
            } else {
                manager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, alarm.getLong("at"), operation)
                Log.w(TAG, "提醒使用非精确任务，可能延迟: id=${alarm.getInt("id")}")
            }
        } catch (error: SecurityException) {
            if (!exact) throw error
            Log.w(TAG, "精确闹钟权限在登记期间撤回，降级提醒: id=${alarm.getInt("id")}", error)
            manager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, alarm.getLong("at"), operation)
            mode = "inexactAllowWhileIdle"
        }
        Log.i(TAG, "提醒已登记: id=${alarm.getInt("id")}, at=${alarm.getLong("at")}, mode=$mode")
        return mode
    }

    /** 尽力释放失效任务，令牌校验继续阻止已经出队的旧广播。 */
    private fun discard(context: Context, alarm: JSONObject) {
        try {
            val operation = PendingIntent.getBroadcast(context, alarm.getInt("id"), fireIntent(context, alarm),
                PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE) ?: return
            (context.getSystemService(Context.ALARM_SERVICE) as AlarmManager).cancel(operation)
            operation.cancel()
        } catch (error: Exception) {
            Log.e(TAG, "释放失效提醒失败: id=${alarm.optInt("id")}", error)
        }
    }

    /** 取消当前编号的系统任务与已显示通知，不触碰其他业务编号。 */
    fun cancel(context: Context, id: Int) {
        val alarm = read(context, id)
        save(context, id, null)
        if (alarm != null) discard(context, alarm)
        (context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager).cancel(id)
    }

    /** 全部关闭时逐一释放已登记的系统任务，展示通知由调用方统一清理。 */
    fun cancelAll(context: Context) {
        for (alarm in alarms(context)) cancel(context, alarm.getInt("id"))
    }

    /** 返回尚未交付的原生任务，已到期但等待系统执行的任务仍保留在列表中。 */
    fun pending(context: Context): List<Map<String, Any>> = alarms(context)
        .filter { !it.optBoolean("delivered") }
        .map { mapOf("id" to it.getInt("id"), "title" to it.getString("title"),
            "body" to it.getString("body"), "payload" to it.getString("payload")) }

    /** 系统恢复或时区变化后重建任务，每日提醒使用设备当前时区。 */
    fun restore(context: Context) {
        for (alarm in alarms(context)) {
            try {
                if (alarm.optBoolean("daily")) {
                    val next = JSONObject(alarm.toString())
                    updateDailyTime(next, System.currentTimeMillis())
                    // 重排换用独立令牌，已经进入系统队列的旧广播不能投递新排期。
                    replace(context, next, alarm)
                    continue
                } else if (alarm.optBoolean("delivered") || alarm.getLong("at") <= System.currentTimeMillis()) {
                    // 过期单次排期直接释放，恢复系统事件不能补发历史纪念日或删除已显示通知。
                    save(context, alarm.getInt("id"), null)
                    discard(context, alarm)
                    continue
                }
                register(context, alarm)
            } catch (error: Exception) {
                Log.e(TAG, "恢复提醒失败: id=${alarm.optInt("id")}", error)
            }
        }
    }

    /** 持久化当前交付结果后再续期，重复广播不能重复提醒。 */
    fun deliver(context: Context, intent: Intent) {
        val id = intent.getIntExtra("id", -1)
        val alarm = read(context, id) ?: return
        if (alarm.getString("token") != intent.getStringExtra(TOKEN) || alarm.optBoolean("delivered")) return
        val now = System.currentTimeMillis()
        if (alarm.optBoolean("daily") && alarm.getString("timeZoneName") != ZoneId.systemDefault().id) {
            val next = JSONObject(alarm.toString())
            updateDailyTime(next, now)
            // 时区广播与到期广播的顺序不固定，先拦住旧时区排期，再等待新当地时刻。
            replace(context, next, alarm)
            return
        }
        if (alarm.getLong("at") > now) return
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.notify(id, notification(context, alarm))
        alarm.put("delivered", true)
        save(context, id, alarm)
        if (alarm.optBoolean("daily")) {
            val next = JSONObject(alarm.toString())
            updateDailyTime(next, System.currentTimeMillis())
            // 下一天使用独立令牌，已投递的广播不会误触发新的周期。
            replace(context, next, alarm)
        } else {
            save(context, id, null)
        }
        Log.i(TAG, "提醒已投递: id=$id")
    }

    /** 使用既有渠道播放一次系统通知提示，应用进程无需保持前台或播放服务。 */
    private fun notification(context: Context, alarm: JSONObject): Notification {
        val details = alarm.getJSONObject("platformSpecifics")
        val visibility = when (details.optInt("visibility", 1)) {
            0 -> NotificationCompat.VISIBILITY_PRIVATE
            2 -> NotificationCompat.VISIBILITY_SECRET
            else -> NotificationCompat.VISIBILITY_PUBLIC
        }
        val builder = NotificationCompat.Builder(context, details.getString("channelId"))
            .setSmallIcon(context.applicationInfo.icon)
            .setContentTitle(alarm.getString("title")).setContentText(alarm.getString("body"))
            .setStyle(NotificationCompat.BigTextStyle().bigText(alarm.getString("body")))
            .setContentIntent(openIntent(context, alarm)).setAutoCancel(true)
            .setCategory(details.optString("category", NotificationCompat.CATEGORY_REMINDER))
            .setPriority(NotificationCompat.PRIORITY_MAX).setVisibility(visibility)
        // Android 8 以上遵循用户在渠道内选择的声振设置，低版本保留应用默认提示。
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            var defaults = 0
            if (details.optBoolean("playSound", true)) defaults = defaults or Notification.DEFAULT_SOUND
            if (details.optBoolean("enableVibration", true)) defaults = defaults or Notification.DEFAULT_VIBRATE
            builder.setDefaults(defaults)
            if (details.optBoolean("playSound", true) && details.has("sound") && !details.isNull("sound")) {
                builder.setSound(Uri.parse(details.getString("sound")))
            }
            val pattern = details.optJSONArray("vibrationPattern")
            if (details.optBoolean("enableVibration", true) && pattern != null) {
                builder.setVibrate(LongArray(pattern.length()) { pattern.getLong(it) })
            }
        }
        return builder.build()
    }
}

/** 系统直接唤醒接收器，Flutter 未启动时仍可交付提醒并登记下一天。 */
class ReminderAlarmReceiver : BroadcastReceiver() {
    /** 广播仅接受自有执行入口和系统恢复事件，失败保留详细原生日志。 */
    override fun onReceive(context: Context, intent: Intent) {
        try {
            when (intent.action) {
                ReminderAlarm.FIRE -> ReminderAlarm.deliver(context, intent)
                Intent.ACTION_BOOT_COMPLETED, Intent.ACTION_MY_PACKAGE_REPLACED,
                Intent.ACTION_TIMEZONE_CHANGED, Intent.ACTION_TIME_CHANGED,
                AlarmManager.ACTION_SCHEDULE_EXACT_ALARM_PERMISSION_STATE_CHANGED -> ReminderAlarm.restore(context)
            }
        } catch (error: Exception) {
            Log.e("ReminderAlarm", "执行系统提醒失败: action=${intent.action}, id=${intent.getIntExtra("id", -1)}", error)
        }
    }
}
