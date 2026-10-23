package com.sesame.notes

import java.io.File
import java.io.IOException
import java.nio.file.Files
import java.nio.file.Path
import org.junit.Assert.assertArrayEquals
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertThrows
import org.junit.Assert.assertTrue
import org.junit.Assume.assumeNoException
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TemporaryFolder

/** 验证更新缓存回收的真实文件效果、重复执行和目录隔离边界。 */
class AppUpdateCacheTest {
    private val cleaner = AppUpdateCache { Files.isSymbolicLink(it.toPath()) }
    @get:Rule
    val temporaryFolder: TemporaryFolder = TemporaryFolder.builder()
        .parentFolder(repositoryTempDirectory())
        .assureDeletion()
        .build()

    /** 下载目录链接到外部时拒绝清理，不能删除链接指向的用户文件。 */
    @Test
    fun rejectsDownloadDirectorySymlinkOutsideRoot() = verifyFilesystemScenario("验证符号链接越界保护") {
        val root = temporaryFolder.newFolder("download-root")
        val outside = temporaryFolder.newFolder("application-data")
        val expected = byteArrayOf(25, 26, 27)
        val protectedFile = writeFixture(outside, "important.apk", expected)
        val link = File(root, "updates").toPath()
        createSymbolicLinkOrSkip(link, outside.toPath())
        try {
            assertThrows("越界更新目录必须报告错误", Exception::class.java) {
                cleaner.clearUnowned(link.toFile(), emptySet())
            }
            assertArrayEquals(expected, protectedFile.readBytes())
        } finally {
            // 先移除测试链接，确保临时目录规则仅清理由本测试创建的普通目录。
            Files.deleteIfExists(link)
        }
    }

    /** 无主安装包和下载残片应被回收，当前待安装的完整文件保持可用。 */
    @Test
    fun removesUnownedPackagesAndPartialsButKeepsPendingInstall() = verifyFilesystemScenario("清理新下载目录中的无主文件") {
        val directory = temporaryFolder.newFolder("updates")
        val pendingBytes = byteArrayOf(1, 2, 3, 4, 5)
        val pending = writeFixture(directory, "pending.apk", pendingBytes)
        val old = writeFixture(directory, "old.apk", byteArrayOf(6, 7, 8))
        val abandoned = writeFixture(directory, "abandoned.apk", byteArrayOf(9, 10))
        val partial = writeFixture(directory, "interrupted.apk.part", byteArrayOf(11))
        val nestedPartial = writeFixture(directory, "download-42/chunks/package.part", byteArrayOf(12, 13))

        assertEquals(8L, cleaner.clearUnowned(directory, setOf(pending)))

        assertArrayEquals(pendingBytes, pending.readBytes())
        for (removed in listOf(old, abandoned, partial, nestedPartial)) {
            assertFalse("无主文件应被回收：${removed.name}", removed.exists())
        }
        assertFalse(File(directory, "download-42").exists())
        assertTrue("系统下载的根目录必须保留", directory.isDirectory)
        assertEquals(0L, cleaner.clearUnowned(directory, setOf(pending)))
    }

    /** 并行系统下载均需保护，不能只保留偏好设置中记录的单个文件。 */
    @Test
    fun preservesEveryActiveDownload() = verifyFilesystemScenario("保护多个活跃下载") {
        val directory = temporaryFolder.newFolder("updates")
        val active = listOf(
            writeFixture(directory, "downloading.apk", byteArrayOf(14, 15)),
            writeFixture(directory, "queued.apk", byteArrayOf(16, 17, 18)),
            writeFixture(directory, "pending-install.apk", byteArrayOf(19, 20, 21, 22)),
        ).associateWith { it.readBytes() }
        val abandoned = writeFixture(directory, "orphan.apk", byteArrayOf(23, 24))

        assertEquals(2L, cleaner.clearUnowned(directory, active.keys))

        active.forEach { (file, expected) -> assertArrayEquals(expected, file.readBytes()) }
        assertFalse(abandoned.exists())
        assertEquals(0L, cleaner.clearUnowned(directory, active.keys))
    }

    /** 顶层子目录含受保护文件时整棵保留，防止破坏进行中的分段下载任务。 */
    @Test
    fun preservesWholeTopLevelDirectoryContainingProtectedFile() = verifyFilesystemScenario("保护下载任务子目录") {
        val directory = temporaryFolder.newFolder("updates")
        val active = writeFixture(directory, "active-task/chunks/current.part", byteArrayOf(25, 26))
        val related = writeFixture(directory, "active-task/metadata", byteArrayOf(27, 28, 29))
        val unrelated = writeFixture(directory, "inactive-task/old.part", byteArrayOf(30, 31, 32, 33))

        assertEquals(4L, cleaner.clearUnowned(directory, setOf(active)))

        assertArrayEquals(byteArrayOf(25, 26), active.readBytes())
        assertArrayEquals(byteArrayOf(27, 28, 29), related.readBytes())
        assertFalse(unrelated.exists())
        assertFalse(File(directory, "inactive-task").exists())
        assertEquals(0L, cleaner.clearUnowned(directory, setOf(active)))
    }

    /** 安装完成且无活跃下载时清空全部残留，空目录继续供系统下载使用。 */
    @Test
    fun emptyProtectionSetClearsEverythingButRetainsDirectory() = verifyFilesystemScenario("安装完成后清空下载残留") {
        val directory = temporaryFolder.newFolder("updates")
        writeFixture(directory, "installed.apk", byteArrayOf(34, 35, 36))
        writeFixture(directory, "interrupted/chunks/old.part", byteArrayOf(37, 38))
        File(directory, "empty-task").also { check(it.mkdirs()) }

        assertEquals(5L, cleaner.clearUnowned(directory, emptySet()))

        assertTrue("根目录不能随安装包一起删除", directory.isDirectory)
        assertTrue("没有受保护任务时不应保留残片", requireNotNull(directory.listFiles()).isEmpty())
        assertEquals(0L, cleaner.clearUnowned(directory, emptySet()))
        assertTrue(directory.isDirectory)
    }

    /** 新目录中的异常条目独立报告，其余无主文件继续回收且允许后续重试。 */
    @Test
    fun unownedNestedSymlinkFailureStillCleansSiblingsAndAllowsRetry() = verifyFilesystemScenario("新下载目录异常隔离与重试") {
        val directory = temporaryFolder.newFolder("updates")
        verifyNestedSymlinkFailureAndRetry(directory) { cleaner.clearUnowned(directory, emptySet()) }
        assertTrue("重试完成后应保留系统下载根目录", directory.isDirectory)
        assertTrue(requireNotNull(directory.listFiles()).isEmpty())
    }

    /** 用真实越界链接验证错误隔离，最后移除链接并检查同一入口能够成功重试。 */
    private fun verifyNestedSymlinkFailureAndRetry(directory: File, clear: () -> Long) {
        try {
            val outside = temporaryFolder.newFolder("protected-data")
            val expected = byteArrayOf(39, 40, 41)
            val protectedFile = writeFixture(outside, "important.apk", expected)
            val nested = File(directory, "interrupted").also { check(it.mkdirs()) }
            val link = File(nested, "escaped").toPath()
            createSymbolicLinkOrSkip(link, outside.toPath())
            try {
                val sibling = writeFixture(directory, "ordinary.apk", byteArrayOf(42, 43))
                val nestedSibling = writeFixture(nested, "ordinary.part", byteArrayOf(44))

                assertThrows("内嵌链接越界必须报告错误", Exception::class.java) { clear() }

                assertFalse("异常条目不得阻止同级安装包清理", sibling.exists())
                assertFalse("异常条目不得阻止同目录下载残片清理", nestedSibling.exists())
                assertArrayEquals(expected, protectedFile.readBytes())
            } finally {
                Files.deleteIfExists(link)
            }

            val retryFile = writeFixture(directory, "retry.apk", byteArrayOf(45, 46, 47, 48))
            assertEquals("解除越界链接后必须允许重新清理", 4L, clear())
            assertFalse(retryFile.exists())
            assertArrayEquals(expected, protectedFile.readBytes())
            assertEquals(0L, clear())
        } catch (error: org.junit.AssumptionViolatedException) {
            throw error
        } catch (error: Exception) {
            throw IllegalStateException("验证嵌套链接错误隔离失败", error)
        }
    }

    /** 环境不支持建链时只跳过对应场景，清理实现产生的异常仍按测试失败报告。 */
    private fun createSymbolicLinkOrSkip(link: Path, target: Path) {
        try {
            Files.createSymbolicLink(link, target)
        } catch (error: IOException) {
            assumeNoException("当前环境无法创建测试符号链接", error)
        } catch (error: UnsupportedOperationException) {
            assumeNoException("当前文件系统不支持符号链接", error)
        } catch (error: SecurityException) {
            assumeNoException("当前环境没有创建符号链接的权限", error)
        }
    }

    /** 在隔离测试目录中写入明确字节，避免依赖真实安装包或设备数据。 */
    private fun writeFixture(parent: File, relativePath: String, content: ByteArray): File {
        try {
            val file = File(parent, relativePath)
            val directory = requireNotNull(file.parentFile) { "测试文件缺少父目录：$file" }
            check(directory.isDirectory || directory.mkdirs())
            file.writeBytes(content)
            return file
        } catch (error: Exception) {
            throw IllegalStateException("创建测试文件失败：$relativePath", error)
        }
    }

    /** 为文件操作异常保留根因堆栈，同时标明失败的业务场景。 */
    private fun verifyFilesystemScenario(description: String, scenario: () -> Unit) {
        try {
            scenario()
        } catch (error: org.junit.AssumptionViolatedException) {
            throw error
        } catch (error: Exception) {
            throw AssertionError("$description 失败：${error.message}", error)
        }
    }

    companion object {
        /** 从 Gradle 或仓库工作目录向上定位项目，所有临时文件仅写入根目录 Temp。 */
        private fun repositoryTempDirectory(): File {
            try {
                val workingDirectory = requireNotNull(System.getProperty("user.dir")) { "测试进程未提供工作目录" }
                val start = File(workingDirectory).canonicalFile
                val repository = generateSequence(start) { it.parentFile }.firstOrNull {
                    File(it, "pubspec.yaml").isFile && File(it, "android/app/build.gradle").isFile
                } ?: throw IllegalStateException("无法从 $start 定位移动端仓库根目录")
                val directory = File(repository, "Temp").canonicalFile
                check(directory.parentFile == repository) { "测试临时目录超出仓库范围" }
                check(directory.isDirectory || directory.mkdirs()) { "无法创建测试临时目录" }
                return directory
            } catch (error: Exception) {
                throw IllegalStateException("准备更新缓存测试临时目录失败", error)
            }
        }
    }
}
