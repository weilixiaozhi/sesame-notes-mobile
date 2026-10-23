package com.sesame.notes

import android.app.Activity
import android.content.ComponentName
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import java.util.Locale

/** 按系统厂商查找可访问的自启动管理页，入口受限时交由界面提供手动路径。 */
internal object AutoStartSettings {
    private const val TAG = "AutoStartSettings"

    /** 只有实际打开自启动页才返回成功，不能把其他系统页面当作自启动入口。 */
    fun open(activity: Activity): Boolean {
        val brands = setOf(Build.MANUFACTURER.lowercase(Locale.ROOT), Build.BRAND.lowercase(Locale.ROOT))
        if (brands.none { it in setOf("oneplus", "oppo", "realme", "oplus") }) {
            Log.i(TAG, "当前厂商没有可确认的自启动直达入口: manufacturer=${Build.MANUFACTURER}, brand=${Build.BRAND}")
            return false
        }

        // 同一系统系列的入口随版本变化，优先检查现行电池管理组件，再尝试已知独立自启动页。
        val components = listOf(
            ComponentName("com.oplus.battery", "com.oplus.startupapp.view.StartupAppListActivity"),
            ComponentName("com.coloros.safecenter", "com.coloros.safecenter.startupapp.StartupAppListActivity"),
            ComponentName("com.coloros.safecenter", "com.coloros.safecenter.permission.startup.StartupAppListActivity"),
            ComponentName("com.oppo.safe", "com.oppo.safe.permission.startup.StartupAppListActivity"),
            ComponentName("com.oneplus.security", "com.oneplus.security.chainlaunch.view.ChainLaunchAppListActivity")
        )
        for (component in components) {
            try {
                val info = activity.packageManager.getActivityInfo(component, 0)
                if (!info.enabled || !info.applicationInfo.enabled || !info.exported) {
                    Log.i(TAG, "自启动入口未开放: component=${component.flattenToShortString()}")
                    continue
                }

                // 已导出的厂商页面仍可能要求系统签名权限；必须按本应用身份核实，避免误报可打开。
                val requiredPermission = info.permission
                if (!requiredPermission.isNullOrEmpty() &&
                    activity.packageManager.checkPermission(requiredPermission, activity.packageName) != PackageManager.PERMISSION_GRANTED) {
                    Log.i(TAG, "自启动入口需要本应用未获授权的权限: component=${component.flattenToShortString()}, permission=$requiredPermission")
                    continue
                }
                activity.startActivity(Intent().setComponent(component))
                Log.i(TAG, "自启动管理页已打开: component=${component.flattenToShortString()}")
                return true
            } catch (error: PackageManager.NameNotFoundException) {
                Log.d(TAG, "当前系统不存在自启动入口: component=${component.flattenToShortString()}")
            } catch (error: Exception) {
                // 查询与启动之间系统策略仍可能变化，保留失败细节并继续核对其他专用入口。
                Log.e(TAG, "自启动入口无法打开: component=${component.flattenToShortString()}", error)
            }
        }
        Log.i(TAG, "系统未提供本应用可访问的自启动入口，需按手动路径设置")
        return false
    }
}
