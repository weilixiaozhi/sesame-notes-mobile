#!/usr/bin/env python3
"""架构基线双仓一致性门禁的回归测试。"""

import hashlib
import os
import unittest
from pathlib import Path
from tempfile import TemporaryDirectory

import check_baseline_sync


BODY_RELATIVE_PATH = check_baseline_sync.BODY_RELATIVE_PATH
MANIFEST_RELATIVE_PATH = check_baseline_sync.MANIFEST_RELATIVE_PATH


def expected_hash(body: str) -> str:
    """用独立实现计算期望哈希，避免测试与门禁共享同一套假设。"""
    return hashlib.sha256(body.encode("utf-8")).hexdigest()


def scaffold(root: Path, body: str, manifest: str | None) -> Path:
    """在临时目录下造一个最小仓库：正文 + 可选的权威副本哈希清单。

    按字节写入，避免 Windows 默认换行翻译让「正文」在写入时被改成 CRLF。
    """
    (root / "docs").mkdir(parents=True, exist_ok=True)
    (root / BODY_RELATIVE_PATH).write_bytes(body.encode("utf-8"))
    if manifest is not None:
        (root / MANIFEST_RELATIVE_PATH).write_bytes(manifest.encode("utf-8"))
    return root


class VerifyTest(unittest.TestCase):
    """覆盖清单一致、漂移、缺失、非法格式与双 checkout 比对。"""

    def test_passes_when_body_matches_manifest(self) -> None:
        body = "# 基线\n\n正文 A\n"
        with TemporaryDirectory() as temp:
            root = scaffold(
                Path(temp),
                body,
                f"{expected_hash(body)}  {BODY_RELATIVE_PATH}",
            )

            _, errors = check_baseline_sync.verify(root)

            self.assertEqual([], errors)

    def test_reports_drift_with_both_hashes(self) -> None:
        body = "# 基线\n\n正文 A\n"
        stale_hash = expected_hash("# 基线\n\n正文 B\n")
        with TemporaryDirectory() as temp:
            root = scaffold(Path(temp), body, f"{stale_hash}  {BODY_RELATIVE_PATH}")

            _, errors = check_baseline_sync.verify(root)

            self.assertEqual(1, len(errors))
            self.assertIn("权威副本哈希清单", errors[0])
            self.assertIn(expected_hash(body), errors[0])
            self.assertIn(stale_hash, errors[0])

    def test_reports_missing_manifest(self) -> None:
        with TemporaryDirectory() as temp:
            root = scaffold(Path(temp), "# 基线\n", None)

            _, errors = check_baseline_sync.verify(root)

            self.assertEqual(1, len(errors))
            self.assertIn("缺失", errors[0])

    def test_rejects_malformed_manifest(self) -> None:
        with TemporaryDirectory() as temp:
            root = scaffold(Path(temp), "# 基线\n", f"not-a-hash  {BODY_RELATIVE_PATH}")

            with self.assertRaises(ValueError):
                check_baseline_sync.read_manifest_hash(root / MANIFEST_RELATIVE_PATH)

    def test_rejects_empty_manifest(self) -> None:
        with TemporaryDirectory() as temp:
            root = scaffold(Path(temp), "# 基线\n", "")

            with self.assertRaises(ValueError):
                check_baseline_sync.read_manifest_hash(root / MANIFEST_RELATIVE_PATH)

    def test_compares_peer_checkout_verbatim(self) -> None:
        body = "# 基线\n\n同一份正文\n"
        manifest = f"{expected_hash(body)}  {BODY_RELATIVE_PATH}"
        with TemporaryDirectory() as temp:
            base = Path(temp)
            root = scaffold(base / "self", body, manifest)
            same = scaffold(base / "peer-same", body, manifest)
            different = scaffold(base / "peer-diff", f"{body}\n多出一行\n", manifest)

            self.assertEqual([], check_baseline_sync.verify(root, same)[1])

            _, errors = check_baseline_sync.verify(root, different)
            self.assertEqual(1, len(errors))
            self.assertIn("逐字一致", errors[0])
            self.assertIn("peer-diff", errors[0])

    def test_repository_body_matches_manifest(self) -> None:
        """防止本仓权威副本哈希清单过期。"""
        _, errors = check_baseline_sync.verify()

        self.assertEqual([], errors)

    def test_repository_body_matches_api_checkout(self) -> None:
        """本地同时具备两个 checkout 时逐字比对（未配置对端目录则跳过）。"""
        peer = os.environ.get("SESAME_NOTES_API_DIR")
        if not peer or not (Path(peer) / BODY_RELATIVE_PATH).is_file():
            return

        _, errors = check_baseline_sync.verify(peer_root=Path(peer))

        self.assertEqual([], errors)


if __name__ == "__main__":
    unittest.main()
