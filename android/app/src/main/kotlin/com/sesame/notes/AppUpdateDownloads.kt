package com.sesame.notes

import android.app.DownloadManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.os.Handler
import android.os.Looper
import android.system.ErrnoException
import android.system.Os
import android.system.OsConstants
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.io.File
import java.security.MessageDigest
import java.util.concurrent.Executors

/** 系统下载任务与持久元数据共同拥有安装包，界面关闭不影响任务生命周期。 */
object AppUpdateDownloads {
    private const val PREFERENCES = "app_update_download"
    private const val CHANNEL = "app_update_downloads"
    private const val NOTICE = 9417
    internal const val PROGRESS_NOTICE = 9418
    private val worker = Executors.newSingleThreadExecutor()
    private val main = Handler(Looper.getMainLooper())
    private var reportedTask = -1L
    private val cache = AppUpdateCache { entry ->
        try {
            // lstat 检查链接本身，不跟随目标；该接口覆盖应用支持的全部 Android 版本。
            OsConstants.S_ISLNK(Os.lstat(entry.path).st_mode)
        } catch (error: ErrnoException) {
            if (error.errno == OsConstants.ENOENT) false else throw error
        }
    }

    /** 启动和安装完成共用下载工作线程回收文件，广播在操作结束后释放。 */
    fun cleanupAsync(context: Context, finish: () -> Unit = {}) {
        try {
            worker.execute {
                try {
                    cleanup(context)
                } finally {
                    finish()
                }
            }
        } catch (error: Exception) {
            Log.e("AppUpdateDownloads", "无法调度更新文件清理，将在下次启动重试", error)
            finish()
        }
    }

    /** 维护当前下载任务与安装文件，读取失败时保留任务目录并等待下次重试。 */
    fun cleanup(context: Context) {
        try {
            // 已安装的构建先撤销系统任务、删除对应 APK，再清理无任务引用的残留。
            status(context, verifyFile = false)
            val directory = File(requireNotNull(context.getExternalFilesDir(Environment.DIRECTORY_DOWNLOADS)).canonicalFile, "updates")
            val protectedFiles = mutableSetOf<File>()
            manifest(context)?.let { protectedFiles.add(file(context, it)) }
            // 安装意图被领取后系统仍可能读取 APK，元数据引用始终保留至安装成功或明确取消。
            val active = DownloadManager.STATUS_PENDING or DownloadManager.STATUS_RUNNING or DownloadManager.STATUS_PAUSED
            requireNotNull(manager(context).query(DownloadManager.Query().setFilterByStatus(active))).use { cursor ->
                while (cursor.moveToNext()) {
                    val local = cursor.getString(cursor.getColumnIndexOrThrow(DownloadManager.COLUMN_LOCAL_URI))
                    val uri = local?.let { Uri.parse(it) }
                    // 无法确认活跃任务的写入位置时停止本次回收，避免删除系统尚在使用的文件。
                    check(uri?.scheme == "file" && !uri.path.isNullOrBlank()) { "无法确认活跃更新任务的文件路径" }
                    protectedFiles.add(File(requireNotNull(uri.path)).canonicalFile)
                }
            }
            val removedBytes = cache.clearUnowned(directory, protectedFiles)
            if (removedBytes > 0) Log.i("AppUpdateDownloads", "已释放无任务引用的安装文件 bytes=$removedBytes")
        } catch (error: Exception) {
            // 元数据或系统任务读取失败时保留当前目录，不能把未知任务当作无主文件。
            Log.e("AppUpdateDownloads", "更新下载目录清理失败，将在下次启动重试", error)
        }
    }

    /** 文件校验与系统查询在工作线程串行执行，结果回到 Flutter 主线程。 */
    fun execute(result: MethodChannel.Result, onMain: ((Any?) -> Any?)? = null, action: () -> Any?) {
        worker.execute {
            try {
                val value = action()
                main.post {
                    try {
                        result.success(if (onMain == null) value else onMain(value))
                    } catch (error: Exception) {
                        Log.e("AppUpdateDownloads", "打开更新界面失败", error)
                        result.error(if (error.message == "UPDATE_WAIT_FOREGROUND") "UPDATE_WAIT_FOREGROUND" else "UPDATE_INSTALL_FAILED",
                            "无法打开系统安装界面", null)
                    }
                }
            } catch (error: Exception) {
                Log.e("AppUpdateDownloads", "更新下载操作失败", error)
                main.post { result.error("UPDATE_DOWNLOAD_FAILED", "更新下载暂不可用，请重试", null) }
            }
        }
    }

    /** 通知订阅只读取系统进度，与入队、取消、安装领取和完成广播共用串行队列。 */
    fun observe(context: Context, onMain: (Map<String, Any?>?) -> Unit) {
        try {
            worker.execute {
                val state = try {
                    status(context, verifyFile = false)?.also { notifyCompleted(context, it) }
                } catch (error: Exception) {
                    Log.e("AppUpdateDownloads", "查询更新通知进度失败，保留系统下载任务", error)
                    null
                }
                main.post { onMain(state) }
            }
        } catch (error: Exception) {
            Log.e("AppUpdateDownloads", "无法调度更新通知进度查询", error)
            main.post { onMain(null) }
        }
    }

    /** 取得应用私有偏好，系统下载编号在进程退出后仍可恢复。 */
    private fun preferences(context: Context) = context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)

    /** 系统下载文件仅落在当前应用的外部私有更新目录。 */
    fun folder(context: Context): File = File(requireNotNull(context.getExternalFilesDir(Environment.DIRECTORY_DOWNLOADS)), "updates").canonicalFile

    /** 校验固定发布协议，下载地址不携带业务账号或明文凭据。 */
    private fun validate(data: JSONObject): JSONObject {
        val uri = Uri.parse(data.getString("url"))
        require(uri.scheme == "https" && !uri.host.isNullOrBlank() && uri.userInfo == null)
        require(data.getString("packageName") == "com.sesame.notes" && data.getString("abi") == "arm64-v8a")
        require(Regex("\\d+\\.\\d+\\.\\d+").matches(data.getString("version")))
        require(data.getLong("buildNumber") > 0 && data.getLong("size") > 0)
        require(Regex("[a-fA-F0-9]{64}").matches(data.getString("sha256")))
        data.put("sha256", data.getString("sha256").lowercase())
        data.getString("notes")
        return data
    }

    /** 持久元数据只包含公开更新信息，不包含用户身份或令牌。 */
    private fun manifest(context: Context): JSONObject? = preferences(context).getString("manifest", null)?.let { validate(JSONObject(it)) }

    /** 生成固定目标文件名，拒绝由界面传入任意文件路径。 */
    private fun file(context: Context, data: JSONObject) = File(folder(context), "update-${data.getString("sha256")}.apk")

    /** 下载器仅能操作当前应用登记的任务。 */
    private fun manager(context: Context) = context.getSystemService(Context.DOWNLOAD_SERVICE) as DownloadManager

    /** 安装成功后清理旧任务，避免再次提示已安装版本。 */
    @Suppress("DEPRECATION")
    private fun installedBuild(context: Context): Long {
        val info = context.packageManager.getPackageInfo(context.packageName, 0)
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) info.longVersionCode else info.versionCode.toLong()
    }

    /** 元数据以标准通道支持的类型传回，界面按同一发布协议复核。 */
    private fun metadata(data: JSONObject): Map<String, Any> = mapOf(
        "version" to data.getString("version"), "buildNumber" to data.getLong("buildNumber"),
        "url" to data.getString("url"), "size" to data.getLong("size"), "sha256" to data.getString("sha256"),
        "notes" to data.getString("notes"), "packageName" to data.getString("packageName"), "abi" to data.getString("abi")
    )

    /** 入队和登记之间进程退出时，按目标文件恢复已创建的系统任务，避免重复下载。 */
    private fun recoverId(context: Context, data: JSONObject): Long {
        val saved = preferences(context).getLong("id", -1)
        if (saved > 0) return saved
        val destination = file(context, data).path
        manager(context).query(DownloadManager.Query()).use { cursor ->
            while (cursor.moveToNext()) {
                val local = cursor.getString(cursor.getColumnIndexOrThrow(DownloadManager.COLUMN_LOCAL_URI))
                val source = cursor.getString(cursor.getColumnIndexOrThrow(DownloadManager.COLUMN_URI))
                if (local != null && Uri.parse(local).path == destination && source == data.getString("url")) {
                    val id = cursor.getLong(cursor.getColumnIndexOrThrow(DownloadManager.COLUMN_ID))
                    check(preferences(context).edit().putLong("id", id).commit())
                    return id
                }
            }
        }
        return -1
    }

    /** 用户主动更新时创建或复用同一任务，恢复已完成包也登记一次安装意图。 */
    fun enqueue(context: Context, values: Map<String, Any?>): Map<String, Any?> {
        val data = validate(JSONObject(values))
        require(data.getLong("buildNumber") > installedBuild(context))
        val previous = manifest(context)
        if (previous != null && previous.getString("sha256") == data.getString("sha256") &&
            previous.getLong("buildNumber") == data.getLong("buildNumber")) {
            val current = status(context)
            if (current != null && current["status"] != "failed") {
                Log.i("AppUpdateDownloads", "复用系统更新任务 id=${current["id"]}")
                check(preferences(context).edit().putBoolean("installPending", true).remove("awaitingPermission").putLong("notified", -1).commit())
                if (current["status"] == "ready") notifyCompleted(context, current)
                return requireNotNull(status(context))
            }
        }
        cancel(context)
        val directory = folder(context)
        check(directory.isDirectory || directory.mkdirs())
        val destination = file(context, data)
        if (destination.exists()) check(destination.delete())
        check(preferences(context).edit().putString("manifest", data.toString()).putLong("id", -1)
            .putBoolean("installPending", true).commit())
        val request = DownloadManager.Request(Uri.parse(data.getString("url")))
            .setDestinationUri(Uri.fromFile(destination))
            .setMimeType("application/vnd.android.package-archive")
            .setTitle("${context.getString(R.string.app_name)} ${data.getString("version")}")
            .setDescription(context.getString(R.string.update_download_background))
            .setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE)
        val id = manager(context).enqueue(request)
        if (!preferences(context).edit().putLong("id", id).commit()) {
            manager(context).remove(id)
            throw IllegalStateException("UPDATE_PERSIST_FAILED")
        }
        Log.i("AppUpdateDownloads", "创建系统更新任务 id=$id build=${data.getLong("buildNumber")}")
        return requireNotNull(status(context))
    }

    /** 撤销系统任务并回收对应安装文件，关闭更新弹窗不调用此方法。 */
    fun cancel(context: Context) {
        val data = manifest(context)
        if (data != null) {
            val id = recoverId(context, data)
            if (id > 0) manager(context).remove(id)
            val destination = file(context, data)
            if (destination.exists() && !destination.delete()) check(!destination.exists())
        }
        check(preferences(context).edit().clear().commit())
        val notifications = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notifications.cancel(NOTICE)
        notifications.cancel(PROGRESS_NOTICE)
    }

    /** 从系统任务恢复状态，只有整包大小和摘要校验通过才进入可安装状态。 */
    fun status(context: Context, verifyFile: Boolean = true): Map<String, Any?>? {
        val data = manifest(context) ?: return null
        if (data.getLong("buildNumber") <= installedBuild(context)) {
            cancel(context)
            return null
        }
        val id = recoverId(context, data)
        if (reportedTask != id && id > 0) {
            reportedTask = id
            Log.i("AppUpdateDownloads", "恢复系统更新任务 id=$id build=${data.getLong("buildNumber")}")
        }
        var state = "failed"
        var found = false
        var received = 0L
        var reason = "DOWNLOAD_REMOVED"
        if (id > 0) manager(context).query(DownloadManager.Query().setFilterById(id)).use { cursor ->
            if (cursor.moveToFirst()) {
                found = true
                received = cursor.getLong(cursor.getColumnIndexOrThrow(DownloadManager.COLUMN_BYTES_DOWNLOADED_SO_FAR)).coerceAtLeast(0)
                reason = cursor.getInt(cursor.getColumnIndexOrThrow(DownloadManager.COLUMN_REASON)).toString()
                state = when (cursor.getInt(cursor.getColumnIndexOrThrow(DownloadManager.COLUMN_STATUS))) {
                    DownloadManager.STATUS_PENDING -> "pending"
                    DownloadManager.STATUS_RUNNING -> "running"
                    DownloadManager.STATUS_PAUSED -> "paused"
                    DownloadManager.STATUS_SUCCESSFUL -> "ready"
                    else -> "failed"
                }
            }
        }
        // 用户在系统通知栏取消任务后，查询记录消失，恢复为可重新下载的空状态。
        if (id > 0 && !found) {
            cancel(context)
            return null
        }
        if (received > data.getLong("size")) {
            manager(context).remove(id)
            state = "failed"
            reason = "UPDATE_SIZE"
        }
        if (state == "ready" && verifyFile) {
            try {
                verify(context, data, force = false)
            } catch (error: Exception) {
                Log.e("AppUpdateDownloads", "安装包完整性校验失败", error)
                manager(context).remove(id)
                (context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager).cancel(NOTICE)
                state = "failed"
                reason = "UPDATE_INTEGRITY"
            }
        }
        // 系统授权页可能导致进程重建；授权确认后只恢复一次安装意图，拒绝授权保持等待。
        if (state == "ready" && preferences(context).getBoolean("awaitingPermission", false) &&
            (Build.VERSION.SDK_INT < Build.VERSION_CODES.O || context.packageManager.canRequestPackageInstalls())) {
            check(preferences(context).edit().putBoolean("installPending", true).remove("awaitingPermission").commit())
            Log.i("AppUpdateDownloads", "安装授权已确认，恢复安装意图 id=$id")
        }
        val snapshot = mapOf("id" to id, "status" to state, "received" to received, "total" to data.getLong("size"),
            "reason" to reason, "manifest" to metadata(data), "installPending" to preferences(context).getBoolean("installPending", false))
        // 应用恢复时补发此前因权限关闭而未送达的完成通知，安装领取后的任务不会重发。
        if (verifyFile) notifyCompleted(context, snapshot)
        return snapshot
    }

    /** 安装前强制重新校验；普通进度查询仅复用未发生变化的已校验文件。 */
    private fun verify(context: Context, data: JSONObject, force: Boolean): File {
        val destination = file(context, data).canonicalFile
        require(destination.parentFile == folder(context) && destination.isFile && destination.length() == data.getLong("size"))
        val fingerprint = "${data.getString("sha256")}:${destination.length()}:${destination.lastModified()}"
        if (force || preferences(context).getString("verified", null) != fingerprint) {
            val digest = MessageDigest.getInstance("SHA-256")
            destination.inputStream().buffered().use { input ->
                val buffer = ByteArray(64 * 1024)
                while (true) {
                    val count = input.read(buffer)
                    if (count < 0) break
                    digest.update(buffer, 0, count)
                }
            }
            val actual = digest.digest().joinToString("") { "%02x".format(it.toInt() and 0xff) }
            require(actual == data.getString("sha256"))
            check(preferences(context).edit().putString("verified", fingerprint).commit())
        }
        return destination
    }

    /** 用户确认的版本与缓存身份同时匹配才返回可安装文件。 */
    fun readyFile(context: Context, build: Long, digest: String): File {
        val data = requireNotNull(manifest(context))
        require(data.getLong("buildNumber") == build && data.getString("sha256") == digest)
        require(status(context)?.get("status") == "ready")
        return verify(context, data, force = true)
    }

    /** 前台领取一次安装意图，拒绝同一任务在多个界面重复调起安装器。 */
    fun consumeInstall(context: Context, id: Long): Boolean {
        val state = status(context) ?: return false
        if (state["id"] != id || state["status"] != "ready" || state["installPending"] != true) return false
        check(preferences(context).edit().putBoolean("installPending", false).remove("awaitingPermission").commit())
        Log.i("AppUpdateDownloads", "领取安装意图 id=$id")
        (context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager).cancel(NOTICE)
        return true
    }

    /** 相同任务在打开安装界面前退到后台时，保留意图供下次前台恢复。 */
    fun restoreInstallIntent(context: Context, id: Long) {
        val data = manifest(context) ?: return
        if (recoverId(context, data) == id) {
            check(preferences(context).edit().putBoolean("installPending", true).remove("awaitingPermission").remove("notified").commit())
            // 安装领取会取消完成通知，前台条件失效后为同一任务恢复可点击的安装入口。
            status(context, verifyFile = false)?.let { notifyCompleted(context, it) }
        }
    }

    /** 跳转系统授权前保存任务等待状态，系统重建应用后仍可继续安装。 */
    fun awaitInstallPermission(context: Context): Long {
        val state = requireNotNull(status(context))
        check(state["status"] == "ready")
        check(preferences(context).edit().putBoolean("awaitingPermission", true).commit())
        return state["id"] as Long
    }

    /** 主线程只提交结果，安装意图的持久变更统一进入下载工作队列。 */
    fun finishInstallLaunch(context: Context, id: Long, opened: Boolean) {
        try {
            worker.execute {
                try {
                    val data = manifest(context) ?: return@execute
                    if (recoverId(context, data) != id) return@execute
                    if (opened) {
                        check(preferences(context).edit().putBoolean("installPending", false).remove("awaitingPermission").commit())
                        (context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager).cancel(NOTICE)
                    } else {
                        restoreInstallIntent(context, id)
                    }
                } catch (error: Exception) {
                    Log.e("AppUpdateDownloads", "保存安装界面启动状态失败 id=$id opened=$opened", error)
                }
            }
        } catch (error: Exception) {
            Log.e("AppUpdateDownloads", "无法调度安装界面状态保存 id=$id opened=$opened", error)
        }
    }

    /** 系统广播只处理登记过的任务，下载结束后发布静音的完成通知。 */
    fun completed(context: Context, id: Long, finish: () -> Unit) {
        worker.execute {
            try {
                // 广播不执行整包摘要计算，应用恢复与安装入口会强制验证。
                val state = status(context, verifyFile = false)
                if (state != null && state["id"] == id) {
                    Log.i("AppUpdateDownloads", "系统更新任务结束 id=$id status=${state["status"]}")
                    notifyCompleted(context, state)
                }
            } catch (error: Exception) {
                Log.e("AppUpdateDownloads", "处理下载完成状态失败", error)
            } finally {
                finish()
            }
        }
    }

    /** 下载与完成共用低打扰渠道，通知图标由应用自身提供。 */
    private fun notificationBuilder(context: Context): NotificationCompat.Builder {
        val notifications = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            notifications.createNotificationChannel(NotificationChannel(CHANNEL, context.getString(R.string.update_download_channel), NotificationManager.IMPORTANCE_LOW).apply {
                setSound(null, null)
                enableVibration(false)
            })
        }
        val intent = Intent(context, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        val pending = PendingIntent.getActivity(context, NOTICE, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        return NotificationCompat.Builder(context, CHANNEL)
            .setSmallIcon(R.drawable.ic_update_download)
            .setContentIntent(pending)
            .setOnlyAlertOnce(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setShowWhen(false)
    }

    /** 持续通知覆盖排队、下载和等待网络，下载字节数转为安全的百分比。 */
    fun progressNotification(context: Context, state: Map<String, Any?>?): Notification {
        val received = (state?.get("received") as? Number)?.toLong()?.coerceAtLeast(0) ?: 0L
        val total = (state?.get("total") as? Number)?.toLong() ?: 0L
        val progress = if (total > 0) (received.toDouble() / total * 100).toInt().coerceIn(0, 100) else 0
        val pending = state == null || state["status"] == "pending"
        val description = when {
            state?.get("status") == "paused" -> context.getString(R.string.update_download_paused)
            pending -> context.getString(R.string.update_download_waiting)
            else -> context.getString(R.string.update_download_progress, progress)
        }
        return notificationBuilder(context)
            .setContentTitle(context.getString(R.string.update_download_running))
            .setContentText(description)
            .setCategory(NotificationCompat.CATEGORY_PROGRESS)
            .setOngoing(true)
            .setAutoCancel(false)
            .setProgress(100, progress, pending || total <= 0)
            .setForegroundServiceBehavior(NotificationCompat.FOREGROUND_SERVICE_IMMEDIATE)
            .build()
    }

    /** 安装意图已领取时不重发完成通知；通知关闭时保留下一次投递机会。 */
    private fun notifyCompleted(context: Context, state: Map<String, Any?>) {
        try {
            val ready = state["status"] == "ready"
            if (!ready && state["status"] != "failed") return
            if (ready && state["installPending"] != true) return
            val id = state["id"] as Long
            if (preferences(context).getLong("notified", -1) == id) return
            val notice = notificationBuilder(context)
                .setContentTitle(context.getString(if (ready) R.string.update_download_ready else R.string.update_download_failed))
                .setContentText(context.getString(if (ready) R.string.update_download_install else R.string.update_download_retry))
                .setAutoCancel(true).build()
            val notifications = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            if (!NotificationManagerCompat.from(context).areNotificationsEnabled()) return
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
                notifications.getNotificationChannel(CHANNEL)?.importance == NotificationManager.IMPORTANCE_NONE) return
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                val group = notifications.getNotificationChannel(CHANNEL)?.group
                if (group != null && notifications.getNotificationChannelGroup(group)?.isBlocked == true) return
            }
            notifications.notify(NOTICE, notice)
            preferences(context).edit().putLong("notified", id).apply()
        } catch (error: Exception) {
            Log.e("AppUpdateDownloads", "更新完成通知发布失败，任务状态保留供应用恢复", error)
        }
    }
}

/** 应用进程退出后仍接收系统下载结果，不在广播中直接打开安装界面。 */
class AppUpdateDownloadReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != DownloadManager.ACTION_DOWNLOAD_COMPLETE) return
        val id = intent.getLongExtra(DownloadManager.EXTRA_DOWNLOAD_ID, -1)
        if (id < 0) return
        val pending = goAsync()
        AppUpdateDownloads.completed(context.applicationContext, id) { pending.finish() }
    }
}

/** 系统确认覆盖安装成功后回收安装包，无需用户再次打开应用。 */
class AppUpdateInstalledReceiver : BroadcastReceiver() {
    /** 仅响应本应用安装完成通知，清理交由后台线程执行。 */
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_MY_PACKAGE_REPLACED) return
        val pending = goAsync()
        AppUpdateDownloads.cleanupAsync(context.applicationContext) { pending.finish() }
    }
}
