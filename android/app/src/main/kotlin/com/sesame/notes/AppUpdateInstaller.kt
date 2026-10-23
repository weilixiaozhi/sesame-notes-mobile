package com.sesame.notes

import android.content.Intent
import android.Manifest
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.util.Log
import androidx.core.content.FileProvider
import androidx.lifecycle.Lifecycle
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.plugin.common.MethodChannel
import java.io.File

/** 独立 Provider 避免与第三方插件的文件共享声明合并。 */
class UpdateFileProvider : FileProvider()

/** 仅接受更新缓存中的本应用正式签名安装包，系统仍负责最终安装确认。 */
object AppUpdateInstaller {
    /** 文件校验与界面启动之间保留系统任务身份，异步结果只作用于同一任务。 */
    private data class PreparedInstall(val intent: Intent, val taskId: Long)

    /** 注册更新通道，下载与校验交给独立工作线程执行。 */
    fun register(activity: FlutterFragmentActivity, channel: MethodChannel) {
        AppUpdateDownloads.cleanupAsync(activity.applicationContext)
        channel.setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "isSupported" -> result.success(
                        activity.packageName == "com.sesame.notes" &&
                            Build.SUPPORTED_ABIS.contains("arm64-v8a")
                    )
                    "canInstall" -> result.success(
                        Build.VERSION.SDK_INT < Build.VERSION_CODES.O ||
                            activity.packageManager.canRequestPackageInstalls()
                    )
                    "openInstallSettings" -> {
                        AppUpdateDownloads.execute(result, onMain = { value ->
                            val id = value as Long
                            requireForeground(activity, id)
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                activity.startActivity(Intent(
                                    Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
                                    Uri.parse("package:${activity.packageName}")
                                ))
                            }
                            null
                        }) { AppUpdateDownloads.awaitInstallPermission(activity.applicationContext) }
                    }
                    "install" -> {
                        val build = requireNotNull(call.argument<Number>("buildNumber")).toLong()
                        val digest = requireNotNull(call.argument<String>("sha256"))
                        AppUpdateDownloads.execute(result, onMain = { value ->
                            val prepared = value as PreparedInstall
                            requireForeground(activity, prepared.taskId)
                            activity.startActivity(prepared.intent)
                            AppUpdateDownloads.finishInstallLaunch(activity.applicationContext, prepared.taskId, opened = true)
                            null
                        }) {
                            val file = AppUpdateDownloads.readyFile(activity, build, digest)
                            val id = requireNotNull(AppUpdateDownloads.status(activity)?.get("id")) as Long
                            PreparedInstall(installIntent(activity, file, build), id)
                        }
                    }
                    "enqueueDownload" -> {
                        val values = requireNotNull(call.arguments as? Map<*, *>).entries.associate {
                            requireNotNull(it.key as? String) to it.value
                        }
                        try {
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
                                activity.lifecycle.currentState.isAtLeast(Lifecycle.State.RESUMED) &&
                                activity.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) {
                                activity.requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), 9417)
                            }
                        } catch (error: Exception) {
                            Log.e("AppUpdateInstaller", "申请更新通知权限失败，继续创建系统下载任务", error)
                        }
                        AppUpdateDownloads.execute(result, onMain = { value ->
                            restoreDownloadNotification(activity, value)
                            value
                        }) { AppUpdateDownloads.enqueue(activity.applicationContext, values) }
                    }
                    "downloadStatus" -> AppUpdateDownloads.execute(result, onMain = { value ->
                        restoreDownloadNotification(activity, value)
                        value
                    }) { AppUpdateDownloads.status(activity.applicationContext) }
                    "cancelDownload" -> AppUpdateDownloads.execute(result) { AppUpdateDownloads.cancel(activity.applicationContext); null }
                    "consumeInstall" -> {
                        val id = requireNotNull(call.argument<Number>("id")).toLong()
                        AppUpdateDownloads.execute(result) { AppUpdateDownloads.consumeInstall(activity.applicationContext, id) }
                    }
                    "restoreInstallIntent" -> {
                        val id = requireNotNull(call.argument<Number>("id")).toLong()
                        AppUpdateDownloads.execute(result) { AppUpdateDownloads.restoreInstallIntent(activity.applicationContext, id); null }
                    }
                    else -> result.notImplemented()
                }
            } catch (error: Exception) {
                Log.e("AppUpdateInstaller", "更新通道操作失败", error)
                result.error("UPDATE_INSTALL_FAILED", "无法打开安装或授权界面", null)
            }
        }
    }

    /** 权限页和安装器均要求原生界面处于前台，延期状态不会丢失安装意图。 */
    private fun requireForeground(activity: FlutterFragmentActivity, id: Long) {
        if (!activity.lifecycle.currentState.isAtLeast(Lifecycle.State.RESUMED)) {
            AppUpdateDownloads.finishInstallLaunch(activity.applicationContext, id, opened = false)
            throw IllegalStateException("UPDATE_WAIT_FOREGROUND")
        }
    }

    /** 原生再次确认前台状态，系统权限弹窗或页面退出不会导致后台强行启动服务。 */
    private fun restoreDownloadNotification(activity: FlutterFragmentActivity, state: Any?) {
        if (activity.lifecycle.currentState.isAtLeast(Lifecycle.State.RESUMED)) {
            AppUpdateDownloadService.ensure(activity.applicationContext, state as? Map<*, *>)
        }
    }

    @Suppress("DEPRECATION")
    /** 包名、版本和签名均匹配时才构造系统安装意图。 */
    private fun installIntent(activity: FlutterFragmentActivity, file: File, expectedBuild: Long): Intent {
        val folder = AppUpdateDownloads.folder(activity)
        val allowed = file.canonicalFile
        require(allowed.parentFile == folder && allowed.isFile)
        require(Regex("update-[a-f0-9]{64}\\.apk").matches(allowed.name))
        require(activity.packageName == "com.sesame.notes")
        val manager = activity.packageManager
        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            PackageManager.GET_SIGNING_CERTIFICATES
        } else PackageManager.GET_SIGNATURES
        val incoming = requireNotNull(manager.getPackageArchiveInfo(allowed.path, flags))
        val installed = manager.getPackageInfo(activity.packageName, flags)
        require(incoming.packageName == installed.packageName)
        val incomingBuild = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            incoming.longVersionCode
        } else incoming.versionCode.toLong()
        val installedBuild = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            installed.longVersionCode
        } else installed.versionCode.toLong()
        require(incomingBuild == expectedBuild && incomingBuild > installedBuild)
        // 当前发布流程固定同一 keystore；不接受缓存路径注入或其他签名的 APK。
        val incomingSigners = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            incoming.signingInfo?.apkContentsSigners
        } else incoming.signatures
        val installedSigners = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            installed.signingInfo?.apkContentsSigners
        } else installed.signatures
        require(!incomingSigners.isNullOrEmpty() && !installedSigners.isNullOrEmpty())
        require(incomingSigners.toSet() == installedSigners.toSet())
        val uri = FileProvider.getUriForFile(activity, "${activity.packageName}.updates", allowed)
        return Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(uri, "application/vnd.android.package-archive")
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
    }
}
