#!/usr/bin/env python3
"""Sesame Notes API Artifact 固定契约测试。"""

import hashlib
import json
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent.parent
ARTIFACT = ROOT / "api/openapi/sesame-notes-api-v1.0.0.json"
EXPECTED_SHA256 = "4FB61737E64D39A45F0282E0379714BB1612D18C438C84490B981EA025329BFA"
HTTP_METHODS = {"get", "post", "put", "patch", "delete"}
ERROR_STATUSES = {"400", "401", "403", "404", "409", "500"}


def _is_unified_error_schema(schema: dict) -> bool:
    """统一错误模型判定：引用 Error 组件，或内联但含 code/message/request_id
    的兼容形态（如导入端点的 400 返回结构化逐条校验明细，属契约设计内例外）。"""
    if schema.get("$ref") == "#/components/schemas/Error":
        return True
    required = schema.get("required", [])
    return all(field in required for field in ("code", "message", "request_id"))


class ApiContractTest(unittest.TestCase):
    """锁定移动端使用的 API v1 字节内容和生成必需元数据。"""

    def test_v1_artifact_is_pinned_by_hash(self) -> None:
        """契约必须作为固定文件入库，任何改动都需显式升级哈希。"""
        content = ARTIFACT.read_bytes()

        self.assertEqual(EXPECTED_SHA256, hashlib.sha256(content).hexdigest().upper())

    def test_v1_artifact_is_ready_for_client_generation(self) -> None:
        """生成客户端依赖稳定操作名和统一错误响应，不得在 Dart 侧猜测。"""
        contract = json.loads(ARTIFACT.read_text(encoding="utf-8"))
        operations = [
            operation
            for path_item in contract["paths"].values()
            for method, operation in path_item.items()
            if method in HTTP_METHODS
        ]
        operation_ids = [operation["operationId"] for operation in operations]

        self.assertEqual("3.0.3", contract["openapi"])
        self.assertEqual("1.0.0", contract["info"]["version"])
        self.assertEqual(49, len(operations))
        self.assertEqual(49, len(set(operation_ids)))
        for operation in operations:
            with self.subTest(operation_id=operation["operationId"]):
                self.assertTrue(ERROR_STATUSES.issubset(operation["responses"]))
                for status in ERROR_STATUSES:
                    schema = operation["responses"][status]["content"][
                        "application/json"
                    ]["schema"]
                    self.assertTrue(
                        _is_unified_error_schema(schema),
                        f"{operation['operationId']} {status} 错误响应必须引用 Error 或与其兼容",
                    )

    def test_transaction_patch_requires_base_revision(self) -> None:
        """交易更新必须提供版本基线，避免调用方绕过乐观锁。"""
        contract = json.loads(ARTIFACT.read_text(encoding="utf-8"))
        operation = contract["paths"][
            "/api/v1/ledgers/{ledger_id}/transactions/{transaction_id}"
        ]["patch"]
        required = operation["requestBody"]["content"]["application/json"]["schema"][
            "required"
        ]

        self.assertIn("base_revision", required)

    def test_transaction_delete_requires_base_revision(self) -> None:
        """交易删除必须提供版本基线，避免 REST 静默覆盖并发更新。"""
        contract = json.loads(ARTIFACT.read_text(encoding="utf-8"))
        operation = contract["paths"][
            "/api/v1/ledgers/{ledger_id}/transactions/{transaction_id}"
        ]["delete"]
        required = operation["requestBody"]["content"]["application/json"]["schema"][
            "required"
        ]

        self.assertIn("base_revision", required)

    def test_pinned_artifact_is_documented_and_checked_in_ci(self) -> None:
        """开发文档和 CI 必须指向同一份契约，避免本地与构建机漂移。"""
        readme = (ROOT / "README.md").read_text(encoding="utf-8")
        workflow = (ROOT / ".github/workflows/test.yml").read_text(encoding="utf-8")

        self.assertIn(ARTIFACT.relative_to(ROOT).as_posix(), readme)
        self.assertIn(EXPECTED_SHA256, readme)
        self.assertNotIn("仓库目前没有已冻结的 OpenAPI Artifact", readme)
        self.assertIn("python3 scripts/test/api_contract_test.py", workflow)

    def test_generator_cleans_the_selected_output_before_generation(self) -> None:
        """全量生成前必须清空受控输出目录，避免已删除端点残留。"""
        script = (
            ROOT / "scripts/openapi/generate_api_client.ps1"
        ).read_text(encoding="utf-8")
        preamble = script[
            script.index("$OutRel =") : script.index("Write-Host '==> normalize_openapi.mjs'")
        ]

        self.assertIn("Remove-Item -LiteralPath $OutDir -Recurse -Force", preamble)
        self.assertIn("$OutDirPath.StartsWith($RootPrefix", preamble)

    def test_generator_check_is_stable_on_windows(self) -> None:
        """Windows 挂载参数不得携带字面引号，比较仅覆盖生成器负责的文件。"""
        script = (
            ROOT / "scripts/openapi/generate_api_client.ps1"
        ).read_text(encoding="utf-8")

        self.assertIn("docker run --rm --mount $Mount", script)
        self.assertNotIn("-v ('\"' +", script)
        self.assertIn("$GeneratedEntries", script)
        self.assertIn("--ignore-cr-at-eol", script)


if __name__ == "__main__":
    unittest.main()
