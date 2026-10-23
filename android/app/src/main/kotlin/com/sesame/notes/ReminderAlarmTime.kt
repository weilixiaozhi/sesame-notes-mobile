package com.sesame.notes

import java.time.Instant
import java.time.ZoneId

/** 每日提醒按当地日历递进，夏令时切换不会改变用户选择的钟面时间。 */
internal object ReminderAlarmTime {
    /** 把设备时区与对应触发时刻保存在一起，避免排期记录使用不同的系统状态。 */
    data class DailySchedule(val timeZoneName: String, val at: Long)

    /** 每日提醒跟随设备时区，返回下一次严格位于未来的当地钟面时间。 */
    fun nextDeviceDaily(hour: Int, minute: Int, now: Long): DailySchedule {
        val zoneName = ZoneId.systemDefault().id
        return DailySchedule(zoneName, nextDaily(hour, minute, zoneName, now))
    }

    /** 取严格晚于当前时刻的下一次同一当地时间，跳过停机期间已经错过的日期。 */
    fun nextDaily(hour: Int, minute: Int, zoneName: String, now: Long): Long {
        val zone = ZoneId.of(zoneName)
        val current = Instant.ofEpochMilli(now).atZone(zone)
        var date = current.toLocalDate()
        // 缺失时刻向后顺延跳时长度，重复时刻选择较早偏移；当天只登记一次。
        var next = date.atTime(hour, minute).atZone(zone)
        if (!next.toInstant().isAfter(current.toInstant())) {
            // 每天从原始钟面时间构造，跳时当天的系统顺延不能污染后续日期。
            date = date.plusDays(1)
            next = date.atTime(hour, minute).atZone(zone)
        }
        return next.toInstant().toEpochMilli()
    }
}
