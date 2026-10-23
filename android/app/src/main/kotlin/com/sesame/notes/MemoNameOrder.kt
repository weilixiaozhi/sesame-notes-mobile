package com.sesame.notes

import android.icu.text.Collator
import android.icu.text.RuleBasedCollator
import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.util.Locale

/** 卡片名称使用固定中文、基础字母权重与自然数字排序。 */
object MemoNameOrder {
    /** 排序只接收名称与身份，不接触卡片字段内容。 */
    fun register(messenger: BinaryMessenger): MethodChannel =
        MethodChannel(messenger, "com.sesame_notes.memo_name_order").also { channel ->
            channel.setMethodCallHandler { call, result ->
                if (call.method != "sortNames") {
                    result.notImplemented()
                } else {
                    try {
                        val entries = (call.arguments as? List<*>)?.map { raw ->
                            val entry = raw as? Map<*, *> ?: error("MEMO_NAME_ORDER_INPUT")
                            val id = entry["id"] as? String ?: error("MEMO_NAME_ORDER_INPUT")
                            val title = entry["title"] as? String ?: error("MEMO_NAME_ORDER_INPUT")
                            id to title
                        } ?: error("MEMO_NAME_ORDER_INPUT")
                        val collator = Collator.getInstance(Locale.SIMPLIFIED_CHINESE) as RuleBasedCollator
                        collator.strength = Collator.PRIMARY
                        collator.numericCollation = true
                        result.success(entries.sortedWith { left, right ->
                            val order = collator.compare(left.second, right.second)
                            if (order == 0) left.first.compareTo(right.first) else order
                        }.map { it.first })
                    } catch (error: Exception) {
                        Log.e("MemoNameOrder", "卡片名称排序失败：${error.javaClass.simpleName}\n${error.stackTrace.joinToString("\n")}")
                        result.error("MEMO_NAME_ORDER_FAILED", "卡片名称排序失败，请重试", null)
                    }
                }
            }
        }
}
