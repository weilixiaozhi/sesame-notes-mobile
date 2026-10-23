package com.sesame.notes

import org.junit.Assert.assertEquals
import org.junit.Test
import java.time.Instant
import java.util.TimeZone

/** 每日续期必须跨进程、跨日期和夏令时保持用户选择的当地钟面时间。 */
class ReminderAlarmTimeTest {
    /** 夏令时开始后仍在纽约上午九点提醒，实际间隔为二十三小时。 */
    @Test fun springForwardPreservesLocalHour() {
        val first = Instant.parse("2027-03-13T14:00:00Z").toEpochMilli()
        assertEquals(Instant.parse("2027-03-14T13:00:00Z").toEpochMilli(),
            ReminderAlarmTime.nextDaily(9, 0, "America/New_York", first))
    }

    /** 夏令时结束后仍在纽约上午九点提醒，实际间隔为二十五小时。 */
    @Test fun fallBackPreservesLocalHour() {
        val first = Instant.parse("2027-11-06T13:00:00Z").toEpochMilli()
        assertEquals(Instant.parse("2027-11-07T14:00:00Z").toEpochMilli(),
            ReminderAlarmTime.nextDaily(9, 0, "America/New_York", first))
    }

    /** 关机数天后只恢复下一次提醒，不逐日补发历史通知。 */
    @Test fun skippedDaysResumeAtNextLocalTime() {
        assertEquals(Instant.parse("2027-01-05T01:00:00Z").toEpochMilli(), ReminderAlarmTime.nextDaily(
            9, 0, "Asia/Shanghai",
            Instant.parse("2027-01-04T02:00:00Z").toEpochMilli()))
    }

    /** 同一天尚未到点时保留当天排期，半小时时区同样按当地时间计算。 */
    @Test fun futureTodayKeepsItsTime() {
        val at = Instant.parse("2027-01-01T03:30:00Z").toEpochMilli()
        assertEquals(at, ReminderAlarmTime.nextDaily(9, 0, "Asia/Kolkata", at - 1000))
    }

    /** 跳时当天二点半顺延到三点半，第二天必须恢复二点半。 */
    @Test fun daylightSavingGapDoesNotShiftSubsequentDays() {
        val gapDay = ReminderAlarmTime.nextDaily(2, 30, "America/New_York",
            Instant.parse("2027-03-14T05:00:00Z").toEpochMilli())
        assertEquals(Instant.parse("2027-03-14T07:30:00Z").toEpochMilli(), gapDay)
        assertEquals(Instant.parse("2027-03-15T06:30:00Z").toEpochMilli(),
            ReminderAlarmTime.nextDaily(2, 30, "America/New_York", gapDay))
    }

    /** 设备从上海切换到东京后，当天尚未到点时按东京九点登记。 */
    @Test fun deviceZoneChangeUsesCurrentLocalHour() {
        val original = TimeZone.getDefault()
        try {
            val now = Instant.parse("2027-01-01T23:00:00Z").toEpochMilli()
            TimeZone.setDefault(TimeZone.getTimeZone("Asia/Shanghai"))
            val shanghai = ReminderAlarmTime.nextDeviceDaily(9, 0, now)
            assertEquals("Asia/Shanghai", shanghai.timeZoneName)
            assertEquals(Instant.parse("2027-01-02T01:00:00Z").toEpochMilli(), shanghai.at)
            TimeZone.setDefault(TimeZone.getTimeZone("Asia/Tokyo"))
            val tokyo = ReminderAlarmTime.nextDeviceDaily(9, 0, now)
            assertEquals("Asia/Tokyo", tokyo.timeZoneName)
            assertEquals(Instant.parse("2027-01-02T00:00:00Z").toEpochMilli(), tokyo.at)
        } finally {
            TimeZone.setDefault(original)
        }
    }

    /** 切换时区后当天已经过点，只安排下一天，不补发当天已经错过的提醒。 */
    @Test fun deviceZoneChangeSkipsPastLocalTime() {
        val original = TimeZone.getDefault()
        try {
            TimeZone.setDefault(TimeZone.getTimeZone("Asia/Tokyo"))
            val next = ReminderAlarmTime.nextDeviceDaily(9, 0,
                Instant.parse("2027-01-02T00:30:00Z").toEpochMilli())
            assertEquals(Instant.parse("2027-01-03T00:00:00Z").toEpochMilli(), next.at)
        } finally {
            TimeZone.setDefault(original)
        }
    }

    /** 秋季重叠的一点半只使用首次出现，首次已到达后跳到第二天。 */
    @Test fun daylightSavingOverlapSchedulesOnlyOneOccurrence() {
        val first = Instant.parse("2027-11-07T05:30:00Z").toEpochMilli()
        assertEquals(first, ReminderAlarmTime.nextDaily(1, 30, "America/New_York", first - 1))
        assertEquals(Instant.parse("2027-11-08T06:30:00Z").toEpochMilli(),
            ReminderAlarmTime.nextDaily(1, 30, "America/New_York", first))
    }

    /** 无效的钟面时间不能静默变成另一项用户偏好。 */
    @Test(expected = java.time.DateTimeException::class)
    fun invalidLocalTimeIsRejected() {
        ReminderAlarmTime.nextDaily(24, 0, "Asia/Shanghai", 1)
    }
}
