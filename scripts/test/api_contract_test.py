#!/usr/bin/env python3
"""Sesame Notes API Artifact 固定契约测试。"""

import hashlib
import json
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent.parent
ARTIFACT = ROOT / "api/openapi/sesame-notes-api-v1.0.0.json"
EXPECTED_SHA256 = "F66E2B2432FC1474497904288921FCAE0ECE43F9FD57D229A3F72ADABFE3B095"
HTTP_METHODS = {"get", "post", "put", "patch", "delete"}
ERROR_STATUSES = {"400", "401", "403", "404", "409", "500"}


def _enum_values(schema: dict) -> set[str]:
    """读取枚举及其可空或纯枚举分支中的业务类型值。"""
    values = set(schema.get("enum", []))
    for branch in schema.get("anyOf", []):
        values.update(_enum_values(branch))
    return values


def _schema_nodes(node: object):
    """遍历选定操作或组件中的 schema 节点，不猜测字段所属领域。"""
    if isinstance(node, dict):
        yield node
        for value in node.values():
            yield from _schema_nodes(value)
    elif isinstance(node, list):
        for value in node:
            yield from _schema_nodes(value)


def _is_unified_error_schema(schema: dict) -> bool:
    """统一错误模型判定：引用 Error 组件，或内联但含 code/message/request_id
    的兼容形态（如导入端点的 400 返回结构化逐条校验明细，属契约设计内例外）。"""
    if schema.get("$ref") == "#/components/schemas/Error":
        return True
    required = schema.get("required", [])
    return all(field in required for field in ("code", "message", "request_id"))


class ApiContractTest(unittest.TestCase):
    """验证核心业务类型、同步数据结构、统一错误和乐观锁契约。"""

    def test_category_removal_requires_explicit_reference_handling(self) -> None:
        """分类删除只允许迁移、删除关联交易或提升子分类。"""
        try:
            contract = json.loads(ARTIFACT.read_text(encoding="utf-8"))
            operation = contract["paths"]["/api/v1/ledgers/{ledger_id}/categories/remove"]["post"]
            mode = operation["requestBody"]["content"]["application/json"]["schema"]["properties"]["mode"]
            self.assertEqual({"migrate", "delete", "promote"}, _enum_values(mode))
        except (OSError, ValueError, KeyError) as error:
            self.fail(f"分类删除契约读取失败：{error}")

    def test_accounting_statistics_contract_has_no_exclusion_fields(self) -> None:
        """所有记账、周期记账及同步载荷只使用完整交易参与统计。"""
        try:
            contract = json.loads(ARTIFACT.read_text(encoding="utf-8"))
            for node in _schema_nodes(contract):
                self.assertNotIn("exclude_from_stats", node.get("properties", {}))
                required = node.get("required", [])
                if isinstance(required, list):
                    self.assertNotIn("exclude_from_stats", required)
                self.assertNotEqual("stats_filter", node.get("name"))
        except (OSError, ValueError) as error:
            raise RuntimeError("无法读取统一记账契约，请检查冻结文件") from error

    def test_accounting_contract_only_allows_expense(self) -> None:
        """记账及资料契约保持只支出，不让其他领域同名 kind 参与判断。"""
        contract = json.loads(ARTIFACT.read_text(encoding="utf-8"))
        schemas = contract["components"]["schemas"]
        roots = [(name, schemas[name]) for name in (
            "Ledger", "Transaction", "Member", "Category", "CategoryConflict",
            "CategoryResolution", "RecurringTransaction", "ExchangeRateOverride",
        )]
        for path, item in contract["paths"].items():
            for method, operation in item.items():
                if method in HTTP_METHODS and set(operation.get("tags", [])) & {
                    "accounting", "categories", "transactions", "ledgers", "profile",
                }:
                    roots.append((f"{method} {path}", operation))
        # 同步 push 是跨领域联合，仅检查明确声明为记账实体的分支。
        push = contract["paths"]["/api/v1/sync/push"]["post"]
        for node in _schema_nodes(push):
            entity = _enum_values(node.get("properties", {}).get("entity_type", {}))
            if entity and entity <= {"ledger", "transaction", "category", "recurring_transaction", "exchange_rate_override", "member"}:
                roots.append((f"sync push {sorted(entity)}", node))
        matched = set()
        for label, schema in roots:
            for node in _schema_nodes(schema):
                properties = node.get("properties", {})
                with self.subTest(schema=label):
                    self.assertNotIn("income_is_red", properties)
                    self.assertNotIn("income_total", properties)
                    for field in ("kind", "tx_type", "category_kind"):
                        if field in properties:
                            matched.add(field)
                            self.assertEqual({"expense"}, _enum_values(properties[field]))
        self.assertEqual({"kind", "tx_type", "category_kind"}, matched)

    def test_fitness_workout_set_kinds_are_scoped_to_workouts(self) -> None:
        """训练组的业务类型只在训练记录端点中校验。"""
        contract = json.loads(ARTIFACT.read_text(encoding="utf-8"))
        matched = 0
        for path in (
            "/api/v1/fitness-spaces/{fitness_space_id}/workouts",
            "/api/v1/fitness-spaces/{fitness_space_id}/workouts/{workout_id}",
        ):
            for node in _schema_nodes(contract["paths"][path]):
                properties = node.get("properties", {})
                if "kind" in properties:
                    matched += 1
                    self.assertEqual({"warmup", "working"}, _enum_values(properties["kind"]))
        self.assertGreater(matched, 0)

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
        self.assertEqual("2.0.0", contract["info"]["version"])
        self.assertTrue(operations)
        self.assertEqual(len(operation_ids), len(set(operation_ids)))
        for operation in operations:
            with self.subTest(operation_id=operation["operationId"]):
                self.assertFalse(any(
                    parameter.get("in") == "header"
                    and parameter.get("name") == "x-sesame-category-ownership"
                    for parameter in operation.get("parameters", [])
                ))
                self.assertTrue(ERROR_STATUSES.issubset(operation["responses"]))
                for status in ERROR_STATUSES:
                    schema = operation["responses"][status]["content"][
                        "application/json"
                    ]["schema"]
                    self.assertTrue(
                        _is_unified_error_schema(schema),
                        f"{operation['operationId']} {status} 错误响应必须引用 Error 或与其兼容",
                    )

        # 两种完整快照与账号快照内的账本块都必须携带有所有者信息的分类墓碑。
        full = contract["paths"]["/api/v1/sync/full"]["get"]["responses"]["200"]["content"]["application/json"]["schema"]
        accounting = contract["paths"]["/api/v1/sync/accounting/full"]["get"]["responses"]["200"]["content"]["application/json"]["schema"]
        for schema in (full, accounting, accounting["properties"]["ledger_snapshots"]["items"]):
            self.assertIn("category_tombstones", schema["required"])
            self.assertEqual({
                "type": "array", "items": {"$ref": "#/components/schemas/Category"},
            }, schema["properties"]["category_tombstones"])
        self.assertNotIn("deleted_category_ids", accounting["properties"])
        self.assertNotIn("deleted_category_ids", accounting["required"])

    def test_transaction_mutations_require_base_revision(self) -> None:
        """交易更新与删除都须提供版本基线，避免绕过乐观锁。"""
        contract = json.loads(ARTIFACT.read_text(encoding="utf-8"))
        path = contract["paths"][
            "/api/v1/ledgers/{ledger_id}/transactions/{transaction_id}"
        ]
        for method in ("patch", "delete"):
            with self.subTest(method=method):
                required = path[method]["requestBody"]["content"]["application/json"][
                    "schema"
                ]["required"]
                self.assertIn("base_revision", required)



if __name__ == "__main__":
    unittest.main()
