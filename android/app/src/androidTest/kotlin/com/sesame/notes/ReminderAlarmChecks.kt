package com.sesame.notes

import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.net.Uri
import org.json.JSONObject
import java.time.Instant
import java.time.LocalTime
import java.time.ZoneId
import java.util.TimeZone

/** 直接调用设备系统排期与广播入口，验证每日提醒重排及旧任务隔离。 */
internal object ReminderAlarmChecks {
    private const val DAILY_ID = 2_140_002_001
    private const val SINGLE_ID = 2_140_002_002
    // 让受控排期远离当前时刻，避免验收期间刚好跨过提醒分钟而触发真实通知。
    private val reminderTime = LocalTime.now(ZoneId.of("Asia/Tokyo")).plusHours(6).withSecond(0).withNano(0)

    /** 使用独立的设备保护存储及测试编号，最后释放全部受控系统任务。 */
    fun run(targetContext: Context) {
        val context = targetContext.createDeviceProtectedStorageContext()
        val originalZone = TimeZone.getDefault()
        try {
            ReminderAlarm.cancel(context, DAILY_ID)
            ReminderAlarm.cancel(context, SINGLE_ID)
            manifestReceivesClockChanges(context)
            scheduleFollowsDeviceZone(context)
            failedReplacementPreservesCurrentAlarm(context)
            restoreRetiresPreviousToken(context)
            timezoneBroadcastPreservesSingleAlarm(context)
            lateOldZoneDeliveryIsReplanned(context)
            cancelledReminderStaysCancelled(context)
        } finally {
            TimeZone.setDefault(originalZone)
            ReminderAlarm.cancel(context, DAILY_ID)
            ReminderAlarm.cancel(context, SINGLE_ID)
        }
    }

    /** 构造完整的现行通道参数，单次任务仍以绝对毫秒时间为准。 */
    private fun arguments(id: Int, daily: Boolean): Map<String, Any?> = mapOf(
        "id" to id, "title" to "时区验收", "body" to "受控提醒正文", "payload" to "/home",
        "at" to System.currentTimeMillis() + 3_600_000,
        "timeZoneName" to "Asia/Shanghai", "daily" to daily,
        "hour" to reminderTime.hour, "minute" to reminderTime.minute,
        "platformSpecifics" to mapOf("channelId" to "reminder_timezone_check",
            "scheduleMode" to "inexactAllowWhileIdle", "playSound" to false, "enableVibration" to false)
    )

    /** 只读取本次测试的任务，缺失记录直接报告断言失败。 */
    private fun alarm(context: Context, id: Int): JSONObject = JSONObject(requireNotNull(
        context.getSharedPreferences("reminder_alarms", Context.MODE_PRIVATE).getString(id.toString(), null)))

    /** 读取系统任务身份，令牌已释放时不允许创建新的 PendingIntent。 */
    private fun operation(context: Context, alarm: JSONObject): PendingIntent? = PendingIntent.getBroadcast(
        context, alarm.getInt("id"), fireIntent(context, alarm),
        PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE)

    /** 使用与生产排期相同的身份构造到期广播，不启动页面或实际等待闹钟。 */
    private fun fireIntent(context: Context, alarm: JSONObject): Intent =
        Intent(context, ReminderAlarmReceiver::class.java).setAction(ReminderAlarm.FIRE)
            .setData(Uri.parse("sesame-reminder://alarm/${alarm.getInt("id")}/${alarm.getString("token")}"))
            .putExtra("id", alarm.getInt("id")).putExtra("reminderAlarmToken", alarm.getString("token"))

    /** 静态接收器必须能在页面和 Flutter 引擎均未启动时接收系统时钟变化。 */
    private fun manifestReceivesClockChanges(context: Context) {
        for (action in listOf(Intent.ACTION_TIMEZONE_CHANGED, Intent.ACTION_TIME_CHANGED)) {
            val receivers = context.packageManager.queryBroadcastReceivers(Intent(action).setPackage(context.packageName), 0)
            check(receivers.any { it.activityInfo.name == ReminderAlarmReceiver::class.java.name }) {
                "清单必须注册时钟恢复广播: $action"
            }
        }
    }

    /** 即使调用参数携带上海时区，也应在当前东京时区的用户钟面时分提醒。 */
    private fun scheduleFollowsDeviceZone(context: Context) {
        TimeZone.setDefault(TimeZone.getTimeZone("Asia/Tokyo"))
        check(ReminderAlarm.schedule(context, arguments(DAILY_ID, true)) == "inexactAllowWhileIdle")
        val scheduled = alarm(context, DAILY_ID)
        assertDailyTime(scheduled, "Asia/Tokyo")
        check(scheduled.getString("title") == "时区验收" && scheduled.getString("body") == "受控提醒正文")
        check(!scheduled.getJSONObject("platformSpecifics").getBoolean("playSound"))
        check(operation(context, scheduled) != null) { "真实系统任务应已登记" }
    }

    /** 系统登记失败必须恢复原记录和旧任务，不能把失败改成排期成功。 */
    private fun failedReplacementPreservesCurrentAlarm(context: Context) {
        val previous = alarm(context, DAILY_ID)
        val invalid = arguments(DAILY_ID, true) +
            ("platformSpecifics" to mapOf("channelId" to "reminder_timezone_check"))
        try {
            ReminderAlarm.schedule(context, invalid)
            error("缺少排期模式必须使登记失败")
        } catch (expected: org.json.JSONException) {
            check(alarm(context, DAILY_ID).toString() == previous.toString()) { "失败后必须恢复完整原记录" }
            check(operation(context, previous) != null) { "旧系统任务必须仍然有效" }
        }
    }

    /** 恢复现有任务保留时分及正文，同时废弃旧令牌和旧系统任务。 */
    private fun restoreRetiresPreviousToken(context: Context) {
        val previous = alarm(context, DAILY_ID)
        TimeZone.setDefault(TimeZone.getTimeZone("Asia/Shanghai"))
        ReminderAlarm.restore(context)
        val restored = alarm(context, DAILY_ID)
        assertDailyTime(restored, "Asia/Shanghai")
        check(restored.getString("token") != previous.getString("token"))
        check(operation(context, previous) == null && operation(context, restored) != null)
        ReminderAlarmReceiver().onReceive(context, fireIntent(context, previous))
        check(alarm(context, DAILY_ID).getString("token") == restored.getString("token")) {
            "已经出队的旧广播不能推进当前任务"
        }
    }

    /** 系统广播重排每日任务，单次提醒的绝对时间与任务身份保持有效。 */
    private fun timezoneBroadcastPreservesSingleAlarm(context: Context) {
        ReminderAlarm.schedule(context, arguments(SINGLE_ID, false))
        val single = alarm(context, SINGLE_ID)
        TimeZone.setDefault(TimeZone.getTimeZone("Asia/Tokyo"))
        ReminderAlarmReceiver().onReceive(context, Intent(Intent.ACTION_TIMEZONE_CHANGED))
        assertDailyTime(alarm(context, DAILY_ID), "Asia/Tokyo")
        val restoredSingle = alarm(context, SINGLE_ID)
        check(restoredSingle.getLong("at") == single.getLong("at"))
        check(restoredSingle.getString("token") == single.getString("token"))
        check(operation(context, restoredSingle) != null)
        ReminderAlarmReceiver().onReceive(context, Intent(Intent.ACTION_TIME_CHANGED))
        assertDailyTime(alarm(context, DAILY_ID), "Asia/Tokyo")
        check(alarm(context, SINGLE_ID).getLong("at") == single.getLong("at"))
    }

    /** 到期广播抢在时区广播前执行时，也只能按新时区重排，不能投递旧钟面时刻。 */
    private fun lateOldZoneDeliveryIsReplanned(context: Context) {
        val previous = alarm(context, DAILY_ID)
        previous.put("timeZoneName", "Asia/Shanghai").put("at", System.currentTimeMillis() - 60_000)
        check(context.getSharedPreferences("reminder_alarms", Context.MODE_PRIVATE).edit()
            .putString(DAILY_ID.toString(), previous.toString()).commit())
        ReminderAlarmReceiver().onReceive(context, fireIntent(context, previous))
        val restored = alarm(context, DAILY_ID)
        assertDailyTime(restored, "Asia/Tokyo")
        check(restored.getString("token") != previous.getString("token"))
        check(operation(context, previous) == null)
        val notifications = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        check(notifications.activeNotifications.none { it.id == DAILY_ID }) { "旧时区广播不能显示通知" }
    }

    /** 用户取消后系统恢复只能处理现存记录，不能复活已经关闭的每日提醒。 */
    private fun cancelledReminderStaysCancelled(context: Context) {
        ReminderAlarm.cancel(context, DAILY_ID)
        ReminderAlarmReceiver().onReceive(context, Intent(Intent.ACTION_TIMEZONE_CHANGED))
        check(ReminderAlarm.pending(context).none { it["id"] == DAILY_ID })
    }

    /** 排期始终位于未来并对应当前时区的原始用户时分。 */
    private fun assertDailyTime(alarm: JSONObject, zoneName: String) {
        check(alarm.getString("timeZoneName") == zoneName)
        val local = Instant.ofEpochMilli(alarm.getLong("at")).atZone(ZoneId.of(zoneName))
        check(local.hour == reminderTime.hour && local.minute == reminderTime.minute && local.second == 0)
        check(alarm.getInt("hour") == reminderTime.hour && alarm.getInt("minute") == reminderTime.minute)
        check(alarm.getLong("at") > System.currentTimeMillis())
    }
}
