#!/usr/bin/env python3
"""Sesame Notes API Artifact 固定契约测试。"""

import hashlib
import json
import subprocess
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent.parent
ARTIFACT = ROOT / "api/openapi/sesame-notes-api-v1.0.0.json"
EXPECTED_SHA256 = "D2B4A9C8BB56AC0C921B456F32FF733D7120E862B8F596ED71EC3E2D0BBAC4F9"
# 内置训练内容与主仓 apps/api/test/fitness-library.test.ts 共用同一份内容哨兵。
FITNESS_LIBRARY = ROOT / "assets/fitness/library.json"
EXPECTED_FITNESS_LIBRARY_SHA256 = "daafbb470c0ff449292b28518ad9fc6b11c44f4c42997f8f672358f76676ded8"
HTTP_METHODS = {"get", "post", "put", "patch", "delete"}
ERROR_STATUSES = {"400", "401", "403", "404", "409", "500"}
TAXONOMY_FIELDS = {
    "id", "name", "is_deleted", "kind", "sort_order", "version",
    "exercise_count", "template_count",
}


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
    """锁定移动端使用的统一契约字节内容和生成必需元数据。"""

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

    def test_analytics_collection_and_catalog_have_distinct_contracts(self) -> None:
        """采集事件、行为目录与统计覆盖分别锁定自己的正式结构。"""
        contract = json.loads(ARTIFACT.read_text(encoding="utf-8"))
        event = contract["paths"]["/api/v1/analytics/events"]["post"]["requestBody"]["content"]["application/json"]["schema"]["properties"]["events"]["items"]
        self.assertEqual({"active", "page_view", "action"}, _enum_values(event["properties"]["kind"]))
        self.assertTrue({"event_id", "occurred_at", "kind", "platform", "session_id", "event_sequence"}.issubset(event["required"]))
        self.assertEqual("uuid", event["properties"]["session_id"]["format"])
        self.assertEqual({"type": "integer", "minimum": 1, "maximum": 2147483647}, event["properties"]["event_sequence"])
        self.assertNotIn("event_name", event["required"])
        self.assertNotIn("flow_id", event["required"])
        event_names = _enum_values(event["properties"]["event_name"])
        page_ids = _enum_values(event["properties"]["page_id"])
        page_view_names = {f"{page_id.replace('.', '_')}_view" for page_id in page_ids}
        self.assertTrue(page_view_names.issubset(event_names))
        self.assertEqual(len(page_ids), len(page_view_names))
        self.assertTrue(all("." not in name for name in event_names))
        self.assertIs(False, event["additionalProperties"])
        catalog = contract["paths"]["/api/v1/admin/analytics/catalog"]["get"]["responses"]["200"]["content"]["application/json"]["schema"]["properties"]["events"]["items"]
        self.assertEqual({"page_view", "action"}, _enum_values(catalog["properties"]["kind"]))
        self.assertEqual({"view", "click", "complete"}, _enum_values(catalog["properties"]["behavior"]))
        self.assertIn("event_name", catalog["required"])
        self.assertEqual({"type": "string"}, catalog["properties"]["event_name"])
        coverage = contract["paths"]["/api/v1/admin/analytics"]["get"]["responses"]["200"]["content"]["application/json"]["schema"]["properties"]["coverage"]
        self.assertEqual({"collection_started_at", "complete"}, set(coverage["properties"]))
        self.assertEqual({"collection_started_at", "complete"}, set(coverage["required"]))

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

    def test_fitness_taxonomies_keep_their_domain_and_catalog_shape(self) -> None:
        """分类管理限定部位与器械两个领域，公开目录在同一快照中提供两类名称。"""
        contract = json.loads(ARTIFACT.read_text(encoding="utf-8"))
        collection = "/api/v1/admin/fitness/taxonomies/{kind}"
        item = f"{collection}/{{taxon_id}}"
        operations = [
            (collection, "get", "listOfficialFitnessTaxonomies", "200"),
            (collection, "post", "createOfficialFitnessTaxonomy", "201"),
            (item, "patch", "updateOfficialFitnessTaxonomy", "200"),
            (item, "delete", "deleteOfficialFitnessTaxonomy", "204"),
        ]
        for path, method, operation_id, status in operations:
            with self.subTest(operation_id=operation_id):
                operation = contract["paths"][path][method]
                self.assertEqual(operation_id, operation["operationId"])
                self.assertEqual([{"adminSessionAuth": []}], operation["security"])
                parameter = next(p for p in operation["parameters"] if p["name"] == "kind")
                self.assertEqual("path", parameter["in"])
                self.assertIs(True, parameter["required"])
                self.assertEqual({"body_part", "equipment"}, _enum_values(parameter["schema"]))
                response = operation["responses"][status]
                if method == "delete":
                    self.assertNotIn("content", response)
                    continue
                schema = response["content"]["application/json"]["schema"]
                if method == "get":
                    self.assertIn("items", schema["required"])
                    schema = schema["properties"]["items"]["items"]
                self.assertTrue(TAXONOMY_FIELDS.issubset(schema["required"]))
                self.assertEqual({"body_part", "equipment"}, _enum_values(schema["properties"]["kind"]))

        catalog = contract["paths"]["/api/v1/fitness/catalog"]["get"]["responses"]["200"]["content"]["application/json"]["schema"]
        # 分类目录可选；提供时部位和器械必须共同到达，避免混用快照。
        self.assertNotIn("taxonomies", catalog["required"])
        taxonomies = catalog["properties"]["taxonomies"]
        self.assertEqual({"body_parts", "equipment"}, set(taxonomies["required"]))
        for category in ("body_parts", "equipment"):
            with self.subTest(category=category):
                schema = taxonomies["properties"][category]
                self.assertEqual("array", schema["type"])
                fields = schema["items"]
                self.assertEqual({"id", "name", "is_deleted"}, set(fields["required"]))
                self.assertEqual("string", fields["properties"]["id"]["type"])
                self.assertEqual(100, fields["properties"]["id"]["maxLength"])
                self.assertEqual("boolean", fields["properties"]["is_deleted"]["type"])
                names = fields["properties"]["name"]
                self.assertEqual({"zh", "zh_hant", "en"}, set(names["required"]))
                self.assertIs(False, names["additionalProperties"])
                for language in names["required"]:
                    self.assertEqual("string", names["properties"][language]["type"])
                    self.assertEqual(1, names["properties"][language]["minLength"])

    def test_v1_artifact_is_pinned_by_hash(self) -> None:
        """契约必须作为固定文件入库，任何改动都需显式升级哈希。"""
        content = ARTIFACT.read_bytes()

        self.assertEqual(EXPECTED_SHA256, hashlib.sha256(content).hexdigest().upper())

    def test_fitness_library_snapshot_matches_shared_sentinel(self) -> None:
        """内置训练内容必须与主仓官方内容逐字节一致，两端任一侧改动都要同时更新哨兵。"""
        content = FITNESS_LIBRARY.read_bytes()

        self.assertEqual(
            EXPECTED_FITNESS_LIBRARY_SHA256,
            hashlib.sha256(content).hexdigest(),
        )

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

    def test_normalization_preserves_constraints_and_is_idempotent(self) -> None:
        """执行真实规范化脚本，避免生成器适配静默丢失额外约束。"""
        result = subprocess.run(
            ["node", "--test", str(ROOT / "scripts/openapi/normalize_openapi.test.mjs")],
            cwd=ROOT, capture_output=True, text=True, encoding="utf-8", check=False,
        )
        self.assertEqual(0, result.returncode, result.stdout + result.stderr)


if __name__ == "__main__":
    unittest.main()
