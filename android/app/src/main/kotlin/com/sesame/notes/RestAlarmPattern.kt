package com.sesame.notes

/** 构造有限时长的交替声振节奏，进程内定时器失效也不会无限振动。 */
internal object RestAlarmPattern {
    const val ALERT_DURATION_MS = 60000L
    /** 保留每轮振动长度，轮间至少停顿七百毫秒，并严格截断到提醒结束时间。 */
    fun forDuration(pattern: LongArray, duration: Long): LongArray {
        require(duration in 1..ALERT_DURATION_MS && pattern.isNotEmpty() && pattern.size <= 1000)
        require(pattern.all { it >= 0 } && pattern.withIndex().any { it.index % 2 == 1 && it.value > 0 })
        val result = mutableListOf<Long>()
        var remaining = duration
        var first = true
        while (remaining > 0) {
            for (index in pattern.indices) {
                val value = if (index == 0 && !first) maxOf(pattern[index], 700) else pattern[index]
                val segment = minOf(value, remaining)
                // 奇数长度以停顿结束，下一轮首段仍是停顿，需要合并以保持开关交替。
                if (index == 0 && !first && pattern.size % 2 == 1) result[result.lastIndex] += segment
                else result.add(segment)
                remaining -= segment
                if (remaining == 0L) break
            }
            first = false
        }
        return result.toLongArray()
    }
}
