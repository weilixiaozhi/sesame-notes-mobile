package com.sesame.notes

import org.junit.Assert.assertArrayEquals
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

/** 验证真实声振节奏的时间上限、轮间停顿和用户自选节奏。 */
class RestAlarmPatternTest {
    /** 正式提醒持续一分钟，振动间歇覆盖整个窗口且不能无限循环。 */
    @Test fun alertLastsOneMinute() {
        assertEquals(60000L, RestAlarmPattern.ALERT_DURATION_MS)
        val result = RestAlarmPattern.forDuration(longArrayOf(0, 1000, 300, 1000), RestAlarmPattern.ALERT_DURATION_MS)
        assertEquals(60000L, result.sum())
        assertEquals(40, result.withIndex().count { it.index % 2 == 1 && it.value == 1000L })
        assertEquals(700L, result.last())
    }

    /** 超过一分钟的请求必须拒绝，自动停止与硬件节奏共用同一上限。 */
    @Test(expected = IllegalArgumentException::class)
    fun rejectsDurationBeyondOneMinute() {
        RestAlarmPattern.forDuration(longArrayOf(0, 1000), 60001)
    }
    /** 两段振动按组重复，十秒边界处必须结束。 */
    @Test fun defaultPatternStopsAtTenSeconds() {
        assertArrayEquals(longArrayOf(0, 1000, 300, 1000, 700, 1000, 300, 1000, 700, 1000, 300, 1000, 700, 1000),
            RestAlarmPattern.forDuration(longArrayOf(0, 1000, 300, 1000), 10000))
    }

    /** 自定义末段为停顿时，下一轮合并停顿而不是翻转开关。 */
    @Test fun oddLengthPatternPreservesOnOffPositions() {
        assertArrayEquals(longArrayOf(100, 200, 750, 200, 750),
            RestAlarmPattern.forDuration(longArrayOf(100, 200, 50), 2000))
    }

    /** 超长用户节奏也只能播放到提醒结束。 */
    @Test fun longSegmentsCannotExceedDeadline() {
        assertArrayEquals(longArrayOf(0, 10000), RestAlarmPattern.forDuration(longArrayOf(0, Long.MAX_VALUE), 10000))
    }

    /** 多种长度均保持有限且恰好达到时间上限。 */
    @Test fun patternsRemainBounded() {
        for (duration in listOf(1L, 999L, 2300L, 9999L, 10000L)) {
            val result = RestAlarmPattern.forDuration(longArrayOf(0, 1, 0, 2), duration)
            assertEquals(duration, result.sum())
            assertTrue(result.all { it >= 0 })
        }
    }

    /** 没有有效振动的输入必须拒绝，避免无限循环。 */
    @Test(expected = IllegalArgumentException::class)
    fun rejectsEmptyVibration() {
        RestAlarmPattern.forDuration(longArrayOf(0, 0, 100), 10000)
    }
}
