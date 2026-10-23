@file:Suppress("DEPRECATION")

package com.sesame.notes

import android.app.Activity
import android.app.DownloadManager
import android.app.Instrumentation
import android.app.Notification
import android.content.ComponentName
import android.content.Context
import android.content.pm.PackageManager
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.Bundle
import android.util.Base64
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.io.File
import java.security.MessageDigest
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit

/** 使用设备真实 DownloadManager 验证持久任务、取消和文件校验，不依赖额外测试框架。 */
class UpdateDownloadInstrumentation : Instrumentation() {
    private var arguments = Bundle()

    /** 保存外部验收参数，所有操作均在测试线程执行。 */
    override fun onCreate(arguments: Bundle?) {
        super.onCreate(arguments)
        this.arguments = arguments ?: Bundle()
        start()
    }

    /** 默认运行离线校验；网络验收可分多次启动验证应用进程退出后的任务恢复。 */
    override fun onStart() {
        val result = Bundle()
        try {
            val context = targetContext
            when (arguments.getString("mode", "checks")) {
                "reminders" -> {
                    ReminderAlarmChecks.run(context)
                    result.putString("stream", "SUCCESS: device timezone, reminder restoration, stale tokens, system clock broadcasts, absolute one-shot time and cancellation\n")
                }
                "enqueue" -> {
                    val encoded = arguments.getString("manifestBase64")
                    val text = if (encoded == null) requireNotNull(arguments.getString("manifest")) else String(Base64.decode(encoded, Base64.DEFAULT), Charsets.UTF_8)
                    val data = JSONObject(text)
                    data.put("buildNumber", installedBuild(context) + 1)
                    val values = data.keys().asSequence().associateWith { data.get(it) }
                    result.putString("state", JSONObject(AppUpdateDownloads.enqueue(context, values)).toString())
                }
                "status" -> result.putString("state", AppUpdateDownloads.status(context)?.let { JSONObject(it).toString() } ?: "null")
                "cancel" -> { AppUpdateDownloads.cancel(context); result.putString("state", "cancelled") }
                else -> { checks(context); result.putString("stream", "SUCCESS: checksum, size, failed-task retry, task restoration, cancellation, cache cleanup, progress notifications, completion race and manifest guards\n") }
            }
            finish(Activity.RESULT_OK, result)
        } catch (error: Exception) {
            result.putString("stream", "FAILED: ${error.stackTraceToString()}\n")
            finish(Activity.RESULT_CANCELED, result)
        }
    }

    /** 获取设备已安装构建号，验收元数据始终使用更高编号。 */
    private fun installedBuild(context: Context): Long {
        val info = context.packageManager.getPackageInfo(context.packageName, 0)
        return if (Build.VERSION.SDK_INT >= 28) info.longVersionCode else info.versionCode.toLong()
    }

    /** 构造系统已经完成的受控文件，验证真实任务查询与校验缓存。 */
    private fun checks(context: Context) {
        AppUpdateDownloads.cancel(context)
        notificationChecks(context)
        val bytes = "download-verification".toByteArray()
        val digest = MessageDigest.getInstance("SHA-256").digest(bytes).joinToString("") { "%02x".format(it.toInt() and 255) }
        val build = installedBuild(context) + 1
        // 保留域名不会提供下载内容，重试检查只依赖系统入队和本地状态清理。
        val metadata = JSONObject().put("version", "1.1.0").put("buildNumber", build)
            .put("url", "https://example.invalid/update.apk").put("size", bytes.size).put("sha256", digest)
            .put("notes", "验收").put("packageName", "com.sesame.notes").put("abi", "arm64-v8a")
        val values = metadata.keys().asSequence().associateWith { metadata.get(it) }
        check(runCatching { AppUpdateDownloads.enqueue(context, values + ("url" to "http://example.com/update.apk")) }.isFailure)
        check(runCatching { AppUpdateDownloads.enqueue(context, values + ("sha256" to "invalid")) }.isFailure)
        check(runCatching { AppUpdateDownloads.enqueue(context, values + ("size" to 0)) }.isFailure)
        check(runCatching { AppUpdateDownloads.enqueue(context, values + ("packageName" to "other")) }.isFailure)
        val folder = AppUpdateDownloads.folder(context)
        check(folder.isDirectory || folder.mkdirs())
        val file = File(folder, "update-$digest.apk")
        file.writeBytes(bytes)
        val manager = context.getSystemService(Context.DOWNLOAD_SERVICE) as DownloadManager
        val id = manager.addCompletedDownload("验收", "验收", false, "application/vnd.android.package-archive", file.path, bytes.size.toLong(), true)
        val preferences = context.getSharedPreferences("app_update_download", Context.MODE_PRIVATE)
        check(preferences.edit().putString("manifest", metadata.toString()).putLong("id", id).putBoolean("installPending", true).commit())
        try {
            check(AppUpdateDownloads.status(context)?.get("status") == "ready")
            check(AppUpdateDownloads.status(context)?.get("id") == id)
            check(AppUpdateDownloads.readyFile(context, build, digest).readBytes().contentEquals(bytes))
            check(AppUpdateDownloads.consumeInstall(context, id))
            check(!AppUpdateDownloads.consumeInstall(context, id))
            AppUpdateDownloads.restoreInstallIntent(context, id + 1)
            check(!preferences.getBoolean("installPending", false)) { "错误任务编号不能恢复安装意图" }
            AppUpdateDownloads.restoreInstallIntent(context, id)
            check(AppUpdateDownloads.consumeInstall(context, id)) { "同一任务延期后必须允许重新领取" }
            check(AppUpdateDownloads.awaitInstallPermission(context) == id)
            check(preferences.getBoolean("awaitingPermission", false)) { "系统授权页打开前必须持久化等待状态" }
            val authorized = Build.VERSION.SDK_INT < Build.VERSION_CODES.O || context.packageManager.canRequestPackageInstalls()
            val afterPermission = requireNotNull(AppUpdateDownloads.status(context))
            if (authorized) {
                check(afterPermission["installPending"] == true && !preferences.contains("awaitingPermission"))
                check(AppUpdateDownloads.consumeInstall(context, id)) { "进程恢复后授权结果必须恢复一次安装机会" }
                check(!AppUpdateDownloads.consumeInstall(context, id)) { "授权恢复只能领取一次" }
            } else {
                check(afterPermission["installPending"] == false && preferences.getBoolean("awaitingPermission", false)) {
                    "拒绝授权必须保留等待状态，不能循环打开授权设置"
                }
            }
            // 错误任务的晚到安装结果不能清除当前任务等待状态。
            AppUpdateDownloads.awaitInstallPermission(context)
            AppUpdateDownloads.finishInstallLaunch(context, id + 1, opened = true)
            awaitDownloadWorker()
            check(preferences.getBoolean("awaitingPermission", false)) { "错误任务的界面结果不能修改当前任务" }
            AppUpdateDownloads.finishInstallLaunch(context, id, opened = true)
            awaitDownloadWorker()
            check(!preferences.getBoolean("installPending", false) && !preferences.contains("awaitingPermission")) {
                "系统安装器成功打开后必须清除安装与授权等待标记"
            }
            // 安装领取后到达的系统广播不能重新发布已完成通知。
            check(preferences.edit().remove("notified").commit())
            val completion = CountDownLatch(1)
            AppUpdateDownloads.completed(context, id) { completion.countDown() }
            check(completion.await(10, TimeUnit.SECONDS)) { "完成广播必须及时释放异步结果" }
            check(!preferences.contains("notified")) { "安装意图已领取后不能重新提示安装" }
            // 安装器已经领取意图时仍需保护完整包，同时回收下载目录中的无主文件。
            val orphan = File(folder, "update-${"0".repeat(64)}.apk")
            orphan.writeBytes(bytes)
            AppUpdateDownloads.cleanup(context)
            check(!orphan.exists()) { "无主安装包应被回收" }
            check(file.readBytes().contentEquals(bytes)) { "安装器读取中的安装包必须保留" }
            check(AppUpdateDownloads.status(context)?.get("id") == id)
            val corrupted = bytes.clone()
            corrupted[0] = (corrupted[0].toInt() xor 1).toByte()
            file.writeBytes(corrupted)
            check(runCatching { AppUpdateDownloads.readyFile(context, build, digest) }.isFailure)
            AppUpdateDownloads.cancel(context)
            check(AppUpdateDownloads.status(context) == null)
            check(!file.exists())
            // 系统记录的下载长度与磁盘文件长度必须同时符合发布元数据。
            file.writeBytes(bytes)
            val sizeId = manager.addCompletedDownload("验收", "验收", false, "application/vnd.android.package-archive", file.path, bytes.size.toLong(), true)
            check(preferences.edit().putString("manifest", metadata.toString()).putLong("id", sizeId)
                .putLong("notified", sizeId).putBoolean("installPending", false).commit())
            check(AppUpdateDownloads.status(context)?.get("status") == "ready")
            check(preferences.contains("verified"))
            file.appendBytes(byteArrayOf(0))
            // 保留失败任务的同一元数据，用户重试必须创建新任务并清理旧文件与缓存。
            val failed = requireNotNull(AppUpdateDownloads.status(context))
            check(failed["status"] == "failed" && failed["id"] == sizeId)
            check(failed["reason"] == "UPDATE_INTEGRITY")
            val retry = AppUpdateDownloads.enqueue(context, values)
            val retryId = retry["id"] as Long
            check(retryId > 0 && retryId != sizeId) { "重试必须返回新的系统下载编号" }
            manager.query(DownloadManager.Query().setFilterById(sizeId)).use { check(!it.moveToFirst()) }
            manager.query(DownloadManager.Query().setFilterById(retryId)).use { check(it.moveToFirst()) }
            check(!file.exists()) { "重试必须清理旧安装包文件" }
            check(preferences.getLong("id", -1) == retryId)
            check(!preferences.contains("verified")) { "重试必须清理旧文件校验缓存" }
            check(preferences.getLong("notified", -1) != sizeId) { "重试必须清理旧任务通知状态" }
            check(retry["manifest"] == failed["manifest"] && retry["installPending"] == true)
            val restored = requireNotNull(AppUpdateDownloads.status(context))
            check(restored["id"] == retryId && restored["manifest"] == retry["manifest"])
            AppUpdateDownloads.cancel(context)
            file.writeBytes(bytes)
            val removedId = manager.addCompletedDownload("验收", "验收", false, "application/vnd.android.package-archive", file.path, bytes.size.toLong(), true)
            check(preferences.edit().putString("manifest", metadata.toString()).putLong("id", removedId).commit())
            manager.remove(removedId)
            check(AppUpdateDownloads.status(context) == null)
            // 已安装构建与待回收任务一致时，安装完成维护必须删除文件并清除任务登记。
            file.writeBytes(bytes)
            val installedId = manager.addCompletedDownload("验收", "验收", false, "application/vnd.android.package-archive", file.path, bytes.size.toLong(), true)
            val installedMetadata = JSONObject(metadata.toString()).put("buildNumber", installedBuild(context))
            check(preferences.edit().putString("manifest", installedMetadata.toString()).putLong("id", installedId).commit())
            AppUpdateDownloads.cleanup(context)
            check(!file.exists() && !preferences.contains("manifest")) { "安装完成后必须自动回收安装包及任务登记" }
            manager.query(DownloadManager.Query().setFilterById(installedId)).use { check(!it.moveToFirst()) }
            // 没有任务登记时也要清理残留，不能在读取空元数据后提前返回。
            orphan.writeBytes(bytes)
            AppUpdateDownloads.cleanup(context)
            check(!orphan.exists()) { "没有任务登记时也必须清理无主安装包" }
        } finally {
            AppUpdateDownloads.cancel(context)
        }
    }

    /** 工作队列屏障只等待此前变更，不额外读取或推进安装权限状态。 */
    private fun awaitDownloadWorker() {
        val completion = CountDownLatch(1)
        var failure: String? = null
        AppUpdateDownloads.execute(object : MethodChannel.Result {
            /** 工作结果回到主线程后解除测试线程等待。 */
            override fun success(result: Any?) { completion.countDown() }
            /** 保存通道错误，测试线程输出明确失败原因。 */
            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                failure = "$errorCode: $errorMessage"
                completion.countDown()
            }
            /** 未实现回调属于队列屏障异常。 */
            override fun notImplemented() { failure = "工作队列屏障未实现"; completion.countDown() }
        }) { null }
        check(completion.await(10, TimeUnit.SECONDS)) { "安装状态变更必须在工作队列中完成" }
        check(failure == null) { requireNotNull(failure) }
    }

    /** 真实 Android 通知构建和清单配置共同保证下载图标、进度与前台服务类型一致。 */
    private fun notificationChecks(context: Context) {
        val pending = AppUpdateDownloads.progressNotification(context, null)
        check(pending.flags and Notification.FLAG_ONGOING_EVENT != 0) { "下载中通知必须标记为持续任务" }
        check(pending.flags and Notification.FLAG_AUTO_CANCEL == 0) { "点击进度通知不能取消下载提示" }
        check(pending.smallIcon.resId == R.drawable.ic_update_download) { "状态栏必须使用应用提供的下载图标" }
        check(pending.extras.getBoolean(Notification.EXTRA_PROGRESS_INDETERMINATE)) { "排队时必须展示等待进度" }
        val running = AppUpdateDownloads.progressNotification(context,
            mapOf("status" to "running", "received" to 25L, "total" to 100L))
        check(running.extras.getInt(Notification.EXTRA_PROGRESS) == 25) { "通知进度必须来自系统下载字节数" }
        check(!running.extras.getBoolean(Notification.EXTRA_PROGRESS_INDETERMINATE))
        val paused = AppUpdateDownloads.progressNotification(context,
            mapOf("status" to "paused", "received" to 25L, "total" to 100L))
        check(paused.extras.getCharSequence(Notification.EXTRA_TEXT).toString() == context.getString(R.string.update_download_paused))
        val service = context.packageManager.getServiceInfo(ComponentName(context, AppUpdateDownloadService::class.java), 0)
        check(!service.exported) { "下载进度服务只能由应用内部启动" }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            check(service.foregroundServiceType and ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC != 0)
        }
        val permissions = context.packageManager.getPackageInfo(context.packageName, PackageManager.GET_PERMISSIONS).requestedPermissions
        check(permissions?.contains("android.permission.FOREGROUND_SERVICE_DATA_SYNC") == true)
    }
}
