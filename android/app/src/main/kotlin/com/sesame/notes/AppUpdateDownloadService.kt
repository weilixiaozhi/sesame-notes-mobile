package com.sesame.notes

import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.util.Log

/** 前台服务展示下载进度，安装包传输及进程退出后的恢复由系统下载管理器负责。 */
class AppUpdateDownloadService : Service() {
    private val handler = Handler(Looper.getMainLooper())
    private var generation = 0
    private var stopped = false
    private val poll = Runnable { refresh() }

    companion object {
        private var requestedTask = -1L

        /** 仅由可见应用入口恢复通知，同一任务的界面轮询不会重复启动服务。 */
        fun ensure(context: Context, state: Map<*, *>?) {
            if (state == null || state["status"] !in setOf("pending", "running", "paused")) return
            val id = state["id"] as? Long ?: return
            if (requestedTask == id) return
            try {
                val intent = Intent(context, AppUpdateDownloadService::class.java).putExtra("id", id)
                requestedTask = id
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) context.startForegroundService(intent)
                else context.startService(intent)
            } catch (error: Exception) {
                requestedTask = -1L
                Log.e("AppUpdateDownloads", "无法启动更新进度通知，系统下载继续运行", error)
            }
        }
    }

    /** 服务不向界面暴露绑定接口，进度数据来自同一系统任务。 */
    override fun onBind(intent: Intent?): IBinder? = null

    /** 先发布前台通知，再异步读取任务，避免磁盘校验阻塞系统启动期限。 */
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        try {
            stopped = false
            generation++
            requestedTask = intent?.getLongExtra("id", -1L) ?: -1L
            handler.removeCallbacks(poll)
            val notification = AppUpdateDownloads.progressNotification(this, null)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                startForeground(AppUpdateDownloads.PROGRESS_NOTICE, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC)
            } else {
                startForeground(AppUpdateDownloads.PROGRESS_NOTICE, notification)
            }
            refresh()
        } catch (error: Exception) {
            Log.e("AppUpdateDownloads", "更新进度通知启动失败，系统下载继续运行", error)
            stopProgress()
        }
        return START_NOT_STICKY
    }

    /** 系统查询与广播共享串行队列，关闭服务后忽略晚到回调。 */
    private fun refresh() {
        val expectedGeneration = generation
        AppUpdateDownloads.observe(this) { state ->
            if (stopped || generation != expectedGeneration) return@observe
            try {
                if (state == null || state["status"] !in setOf("pending", "running", "paused")) {
                    stopProgress()
                    return@observe
                }
                // 更新前台通知会保留下载图标与进度，不发出声音或重复提醒。
                val manager = getSystemService(NOTIFICATION_SERVICE) as android.app.NotificationManager
                manager.notify(AppUpdateDownloads.PROGRESS_NOTICE, AppUpdateDownloads.progressNotification(this, state))
                handler.postDelayed(poll, 2000)
            } catch (error: Exception) {
                Log.e("AppUpdateDownloads", "刷新更新进度通知失败，系统下载继续运行", error)
                stopProgress()
            }
        }
    }

    /** Android 15 达到后台同步时限时立即退出前台，独立的系统下载继续保存进度。 */
    override fun onTimeout(startId: Int, fgsType: Int) {
        Log.w("AppUpdateDownloads", "更新进度服务达到系统时限 type=$fgsType，系统下载继续运行")
        stopProgress()
    }

    /** 进度与完成通知使用独立编号，退出前台只移除下载中的通知。 */
    private fun stopProgress() {
        stopped = true
        generation++
        handler.removeCallbacks(poll)
        try {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } catch (error: Exception) {
            Log.e("AppUpdateDownloads", "移除更新进度通知失败", error)
        } finally {
            try {
                stopSelf()
            } catch (error: Exception) {
                Log.e("AppUpdateDownloads", "停止更新进度服务失败", error)
            }
        }
    }

    /** 服务退出只清理订阅，不撤销系统下载任务。 */
    override fun onDestroy() {
        stopped = true
        generation++
        requestedTask = -1L
        handler.removeCallbacks(poll)
        super.onDestroy()
    }
}
