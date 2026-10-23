package com.sesame.notes

import java.io.File
import java.io.IOException

/** 回收未被更新任务引用的安装文件，平台提供链接识别以保证不同文件系统上的删除边界一致。 */
class AppUpdateCache(private val isSymbolicLink: (File) -> Boolean) {
    /** 清理未被任务引用的更新文件，保留下载根目录及包含受保护文件的子目录。 */
    fun clearUnowned(directory: File, protectedFiles: Set<File>): Long {
        try {
            if (isSymbolicLink(directory)) throw IOException("更新下载目录是链接：$directory")
            if (!directory.exists()) return 0
            val root = directory.absoluteFile
            if (root.canonicalFile != root || !root.isDirectory) {
                throw IOException("更新下载目录无效或发生跳转：$root")
            }
            val retained = protectedFiles.map { it.canonicalFile }
            val children = root.listFiles() ?: throw IOException("无法读取更新下载目录：$root")
            var removedBytes = 0L
            var failure: IOException? = null
            for (child in children) {
                // 活跃文件可能处于子目录；保留其父目录，避免递归清理打断系统写入。
                if (retained.any { it == child || it.path.startsWith(child.path + File.separator) }) continue
                try {
                    removedBytes += deleteTree(child)
                } catch (error: IOException) {
                    if (failure == null) failure = error else failure.addSuppressed(error)
                }
            }
            if (failure != null) throw failure
            return removedBytes
        } catch (error: Exception) {
            throw IOException("无法清理无任务引用的更新文件：$directory", error)
        }
    }

    /** 逐项回收文件；拒绝链接跳转，一项失败仍继续清理同目录的其他文件。 */
    private fun deleteTree(entry: File): Long {
        try {
            // 路径必须仍指向遍历到的原位置，不能沿目录链接删除其他应用文件。
            if (isSymbolicLink(entry) || entry.canonicalFile != entry.absoluteFile) {
                throw IOException("更新缓存路径发生跳转：$entry")
            }
            var removedBytes = 0L
            if (entry.isDirectory) {
                val children = entry.listFiles() ?: throw IOException("无法读取更新缓存目录：$entry")
                var failure: IOException? = null
                for (child in children) {
                    try {
                        removedBytes += deleteTree(child)
                    } catch (error: IOException) {
                        if (failure == null) failure = error else failure.addSuppressed(error)
                    }
                }
                // 保留未完成的目录，下次启动可以再次尝试，不记录永久完成标记。
                if (failure != null) throw failure
            } else {
                removedBytes = entry.length()
            }
            if (!entry.delete() && entry.exists()) throw IOException("无法删除更新缓存：$entry")
            return removedBytes
        } catch (error: Exception) {
            throw IOException("回收更新缓存失败：$entry", error)
        }
    }
}
