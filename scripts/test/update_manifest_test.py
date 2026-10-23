"""更新元数据的版本、产物匹配和摘要检查，临时数据仅放仓库 Temp 目录。"""

import hashlib
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from generate_update_manifest import create_manifest

ROOT = Path(__file__).resolve().parents[2]


class UpdateManifestTest(unittest.TestCase):
    """验证正式包元数据和非法版本、仓库、产物的拒绝行为。"""

    def test_manifest_and_invalid_inputs(self):
        """在独立目录中核对产物大小、摘要、下载地址和版本约束。"""
        temp_root = ROOT / 'Temp'
        try:
            temp_root.mkdir(exist_ok=True)
        except OSError as error:
            print(f'无法创建更新元数据测试目录：{error}', file=sys.stderr)
            raise
        with tempfile.TemporaryDirectory(prefix="sesame-notes-update-manifest-", dir=temp_root) as work:
            apk = Path(work) / "Sesame-Notes-prod-v1.0.0.apk"
            apk.write_bytes(b"test apk")
            manifest = create_manifest(apk, "1.0.0+2", "owner/app", "更新说明")
            self.assertEqual(manifest["buildNumber"], 2)
            self.assertEqual(manifest["size"], 8)
            self.assertEqual(manifest["sha256"], hashlib.sha256(b"test apk").hexdigest())
            self.assertEqual(manifest["notes"], "更新说明")
            self.assertEqual(manifest["url"], "https://github.com/owner/app/releases/download/v1.0.0/Sesame-Notes-prod-v1.0.0.apk")
            for version, repository in [("1.0.0", "owner/app"), ("1.0.0+0", "owner/app"), ("1.0.1+2", "owner/app"), ("1.0.0+2", "invalid")]:
                with self.subTest(version=version, repository=repository):
                    with self.assertRaises(ValueError):
                        create_manifest(apk, version, repository, "")
            legacy = Path(work) / "Sesame-Notes-v1.0.0.apk"
            legacy.write_bytes(b"legacy apk")
            with self.assertRaises(ValueError):
                create_manifest(legacy, "1.0.0+2", "owner/app", "")
            test_apk = Path(work) / "Sesame-Notes-test-v1.0.0.apk"
            test_apk.write_bytes(b"test package")
            with self.assertRaises(ValueError):
                create_manifest(test_apk, "1.0.0+2", "owner/app", "")
            alternate_abi = Path(work) / "Sesame-Notes-prod-v1.0.0-android-x64.apk"
            alternate_abi.write_bytes(b"alternate ABI")
            with self.assertRaises(ValueError):
                create_manifest(alternate_abi, "1.0.0+2", "owner/app", "")
            apk.write_bytes(b"")
            with self.assertRaises(ValueError):
                create_manifest(apk, "1.0.0+2", "owner/app", "")


if __name__ == "__main__":
    unittest.main()
