#!/usr/bin/env python3
"""Sesame Notes 项目标识契约测试。"""

import json
import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent.parent


class ProjectIdentityTest(unittest.TestCase):
    """锁定项目名称、版本、导入前缀与发布产物品牌。"""

    def test_pubspec_uses_sesame_notes_identity(self) -> None:
        """pubspec 必须声明 v1.0.0 的全新 Sesame Notes package。"""
        pubspec = (ROOT / "pubspec.yaml").read_text(encoding="utf-8")

        self.assertRegex(pubspec, r"(?m)^name: sesame_notes$")
        self.assertRegex(pubspec, r'(?m)^description: "Sesame Notes - 芝麻记"$')
        self.assertRegex(pubspec, r"(?m)^version: 1\.0\.0\+1$")

    def test_dart_sources_do_not_import_the_old_root_package(self) -> None:
        """根工程源码与测试只能通过 sesame_notes 前缀互相导入。"""
        offenders = [
            path.relative_to(ROOT).as_posix()
            for source_root in ("lib", "test", "scripts", "integration_test", "e2e")
            if (directory := ROOT / source_root).exists()
            for path in directory.rglob("*.dart")
            if re.search(r"package:spitout/", path.read_text(encoding="utf-8"))
        ]

        self.assertEqual([], offenders)

    def test_architecture_gates_use_the_new_package_prefix(self) -> None:
        """依赖图与 CI 门禁必须继续识别根工程的内部导入。"""
        cycle_check = (ROOT / "scripts/test/check_cycles.py").read_text(encoding="utf-8")
        workflow = (ROOT / ".github/workflows/test.yml").read_text(
            encoding="utf-8"
        )

        self.assertNotIn("package:spitout/", cycle_check)
        self.assertNotIn("Provider 叶子白名单门禁", workflow)
        self.assertNotIn("package:sesame_notes/providers/", workflow)
        self.assertNotIn("package:spitout/providers/", workflow)
        self.assertIn("python3 scripts/test/project_identity_test.py", workflow)

    def test_default_ci_excludes_real_backend_e2e(self) -> None:
        """普通 CI 只跑本地测试，真实后端 E2E 必须保留独立入口。"""
        workflow = (ROOT / ".github/workflows/test.yml").read_text(encoding="utf-8")
        e2e_path = ROOT / "e2e/real_backend_roundtrip_test.dart"

        self.assertIn(
            "run: flutter test test --test-randomize-ordering-seed=random",
            workflow,
        )
        self.assertFalse((ROOT / "test/core/api/real_backend_roundtrip_test.dart").exists())
        self.assertTrue(e2e_path.is_file())
        e2e_source = e2e_path.read_text(encoding="utf-8")
        self.assertIn(
            "flutter test e2e/real_backend_roundtrip_test.dart",
            e2e_source,
        )
        self.assertIn("backend_e2e:", workflow)
        self.assertIn(
            "flutter test e2e/real_backend_roundtrip_test.dart", workflow
        )

    def test_ci_self_checks_every_local_package_with_one_matrix(self) -> None:
        """Core、三种 adapter 与 API client 必须逐包执行依赖、分析和测试。"""
        workflow = (ROOT / ".github/workflows/test.yml").read_text(
            encoding="utf-8"
        )
        self.assertIn("package_self_check:", workflow)
        for package in (
            "sesame_api_client",
            "sesame_cloud_backup",
            "sesame_cloud_backup_s3",
            "sesame_cloud_backup_supabase",
            "sesame_cloud_backup_webdav",
        ):
            with self.subTest(package=package):
                self.assertIn(f"- {package}", workflow)
        self.assertIn("packages/${{ matrix.package }}", workflow)
        self.assertIn(
            "flutter pub get && flutter analyze --no-pub && flutter test --no-pub",
            workflow,
        )

    def test_headless_real_backend_tests_must_not_skip(self) -> None:
        """本机可自行启动后端，普通 Flutter 测试不得静默跳过真实链路。"""
        source = (
            ROOT / "e2e/real_backend_roundtrip_test.dart"
        ).read_text(encoding="utf-8")

        self.assertNotIn("markTestSkipped", source)
        self.assertNotIn("backendUp", source)
        self.assertIn(
            "docker compose -f deploy/docker-compose.dev.yml up -d postgres",
            source,
        )
        self.assertIn(
            "docker compose -f deploy/docker-compose.dev.yml run --rm api node apps/api/node_modules/prisma/build/index.js migrate deploy --schema apps/api/prisma/schema.prisma",
            source,
        )
        self.assertIn(
            "docker compose -f deploy/docker-compose.dev.yml up -d api",
            source,
        )
        self.assertIn("后端不可达，真实后端测试禁止跳过", source)

    def test_openapi_check_uses_pwsh_shell(self) -> None:
        """Linux Runner 必须通过已安装的 pwsh 直接执行生成校验脚本。"""
        workflow = (ROOT / ".github/workflows/test.yml").read_text(
            encoding="utf-8"
        )
        step = workflow[
            workflow.index("      - name: OpenAPI 生成一致性校验") :
        ]

        self.assertRegex(step, r"\A[^\n]+\n        shell: pwsh\n        run: \|")
        self.assertIn("./scripts/openapi/generate_api_client.ps1 -Check", step)
        self.assertNotIn(
            "powershell -File scripts/openapi/generate_api_client.ps1",
            step,
        )

    def test_temporary_probe_and_empty_maintenance_facade_are_removed(self) -> None:
        """一次性探针和空 Provider 门面不得进入生产仓库或公共导出。"""
        self.assertFalse((ROOT / "scratch_probe_race_test.dart").exists())
        self.assertFalse(
            (ROOT / "lib/providers/maintenance/maintenance_providers.dart").exists()
        )

    def test_provider_mega_barrel_is_removed(self) -> None:
        """Provider 聚合 barrel 已拆除，依赖必须指向叶子 Provider。

        barrel 一旦重建，任一出口变化都会放大重编译范围并隐藏真实依赖，
        因此本门禁同时禁止文件复活与新增 importer。
        """
        barrel = ROOT / "lib" / "providers" / "providers.dart"
        self.assertFalse(barrel.exists(), "providers/providers.dart 不得重新引入")

        offenders = [
            path.relative_to(ROOT).as_posix()
            for sub in ("lib", "test", "integration_test", "e2e")
            for path in (ROOT / sub).rglob("*.dart")
            if "package:sesame_notes/providers/providers.dart"
            in path.read_text(encoding="utf-8")
        ]
        self.assertEqual([], offenders)

    def test_presentation_does_not_touch_repository_providers(self) -> None:
        """UI 层不得直连仓储大门面，写用例与查询必须经 feature 用例层。

        直连会让写用例、校验与刷新策略散落在页面里，页面测试也不得不 mock
        整个仓储。存量已迁至 application，此处锁死回归：presentation 与
        shared/widgets 不得再出现 repositoryProvider 的读/听/失效调用。
        """
        use_re = re.compile(
            r"ref\s*\.\s*(read|watch|refresh|invalidate|listen)\s*\(\s*"
            r"\w*[Rr]epository\w*Provider"
        )
        offenders = []
        for path in sorted((ROOT / "lib").rglob("*.dart")):
            parts = path.relative_to(ROOT / "lib").parts
            is_ui = (parts[0] == "shared" and len(parts) > 1 and parts[1] == "widgets") or (
                parts[0] == "features" and len(parts) > 2 and parts[2] == "presentation"
            )
            if not is_ui:
                continue
            source = path.read_text(encoding="utf-8")
            for match in use_re.finditer(source):
                line = source.count("\n", 0, match.start()) + 1
                call = " ".join(match.group(0).split())
                offenders.append(
                    f"{path.relative_to(ROOT).as_posix()}:{line}: {call}"
                )

        self.assertEqual([], offenders)

    def test_shared_widgets_do_not_depend_on_feature_application(self) -> None:
        """共享控件不得反向读取业务 application；业务组件应归属对应 feature。"""
        shared_widgets = ROOT / "lib/shared/widgets"
        offenders = [
            path.relative_to(ROOT).as_posix()
            for path in sorted(shared_widgets.rglob("*.dart"))
            if re.search(
                r"(?m)^import 'package:sesame_notes/features/.+/application/",
                path.read_text(encoding="utf-8"),
            )
        ]
        self.assertEqual([], offenders)

    def test_move_to_cloud_action_is_wired_to_ui(self) -> None:
        """本地账本迁云动作必须在账本编辑页有真实 UI 调用，防止重构漏接。"""
        page = (
            ROOT / "lib/features/ledgers/presentation/ledger_edit_page.dart"
        ).read_text(encoding="utf-8")

        self.assertIn("moveToCloud", page)

    def test_sharing_service_exposes_only_consumed_operations(self) -> None:
        """App 共享门面只保留现有用例消费的方法，生成契约不受影响。"""
        source = (ROOT / "lib/core/api/sharing_service.dart").read_text(
            encoding="utf-8"
        )

        for unused in (
            "listMembers",
            "listInvites",
            "sharedResources",
            "leaveLedger",
        ):
            with self.subTest(unused=unused):
                self.assertNotIn(unused, source)

    def test_cross_cutting_leaf_modules_do_not_import_features(self) -> None:
        """Theme、Logger 与 l10n 只能作为叶子支撑，不得反向依赖业务。"""
        offenders = [
            path.relative_to(ROOT).as_posix()
            for directory in (
                ROOT / "lib/theme",
                ROOT / "lib/core/logging",
                ROOT / "lib/l10n",
            )
            for path in sorted(directory.rglob("*.dart"))
            if "package:sesame_notes/features/"
            in path.read_text(encoding="utf-8")
        ]

        self.assertEqual([], offenders)

    def test_core_does_not_import_backup_adapters(self) -> None:
        """Core 只依赖备份契约，不得绑定 S3、Supabase 或 WebDAV adapter。"""
        adapter_import = re.compile(
            r"package:sesame_cloud_backup_(?:s3|supabase|webdav)/"
        )
        offenders = [
            path.relative_to(ROOT).as_posix()
            for path in sorted((ROOT / "lib/core").rglob("*.dart"))
            if adapter_import.search(path.read_text(encoding="utf-8"))
        ]

        self.assertEqual([], offenders)

    def test_ledger_ui_uses_display_model_instead_of_drift_row(self) -> None:
        """账本 UI 只能消费展示模型，Drift Ledger Row 不得再由模型门面导出。"""
        models = (ROOT / "lib/data/models.dart").read_text(encoding="utf-8")
        providers = (
            ROOT / "lib/shared/providers/database_providers.dart"
        ).read_text(encoding="utf-8")

        self.assertNotRegex(models, r"(?m)^\s{8}Ledger,$")
        self.assertRegex(
            providers,
            r"currentLedgerDisplayProvider\s*=\s*\w*Provider<[^;]*LedgerDisplayItem\?",
        )
        ui_row_reads = []
        read_re = re.compile(
            r"ref\s*\.\s*(?:read|watch|listen)\s*\(\s*currentLedgerProvider"
        )
        for path in sorted((ROOT / "lib").rglob("*.dart")):
            parts = path.relative_to(ROOT / "lib").parts
            is_ui = (parts[0] == "shared" and len(parts) > 1 and parts[1] == "widgets") or (
                parts[0] == "features" and len(parts) > 2 and parts[2] == "presentation"
            )
            if is_ui and read_re.search(path.read_text(encoding="utf-8")):
                ui_row_reads.append(path.relative_to(ROOT).as_posix())
        self.assertEqual([], ui_row_reads)

    def test_member_ui_uses_display_model_instead_of_drift_row(self) -> None:
        """成员 UI 只能消费展示模型，Drift LedgerMember 不得由模型门面导出。"""
        models = (ROOT / "lib/data/models.dart").read_text(encoding="utf-8")
        self.assertNotRegex(models, r"(?m)^\s{8}LedgerMember,$")
        self.assertIn("models/ledger_member_display.dart", models)

        offenders = []
        member_row = re.compile(r"(?<!Display)\bLedgerMember\b")
        row_provider = re.compile(
            r"ref\s*\.\s*(?:read|watch|listen|invalidate)\s*\(\s*"
            r"ledger(?:Members|VirtualUsers)Provider"
        )
        for path in sorted((ROOT / "lib").rglob("*.dart")):
            parts = path.relative_to(ROOT / "lib").parts
            is_ui = (parts[0] == "shared" and len(parts) > 1 and parts[1] == "widgets") or (
                parts[0] == "features" and len(parts) > 2 and parts[2] == "presentation"
            )
            if is_ui:
                source = path.read_text(encoding="utf-8")
                if member_row.search(source) or row_provider.search(source):
                    offenders.append(path.relative_to(ROOT).as_posix())
        self.assertEqual([], offenders)

    def test_category_ui_uses_display_model_instead_of_drift_row(self) -> None:
        """分类 UI 只能消费展示模型，Drift Category Row 不得由模型门面导出。"""
        models = (ROOT / "lib/data/models.dart").read_text(encoding="utf-8")
        self.assertNotRegex(models, r"export 'db\.dart' show[^;]*\bCategory\b")
        self.assertIn("models/category_display.dart", models)

        offenders = []
        for path in sorted((ROOT / "lib").rglob("*.dart")):
            parts = path.relative_to(ROOT / "lib").parts
            is_ui = (parts[0] == "shared" and len(parts) > 1 and parts[1] == "widgets") or (
                parts[0] == "features" and len(parts) > 2 and parts[2] == "presentation"
            )
            if not is_ui:
                continue
            source = path.read_text(encoding="utf-8")
            if "package:sesame_notes/data/db.dart" in source or re.search(
                r"\bdb\.Category\b", source
            ):
                offenders.append(path.relative_to(ROOT).as_posix())
        self.assertEqual([], offenders)

    def test_transaction_ui_uses_display_model_instead_of_drift_row(self) -> None:
        """交易 UI 只能消费展示模型，Drift Transaction Row 不得由模型门面导出。"""
        models = (ROOT / "lib/data/models.dart").read_text(encoding="utf-8")
        self.assertNotRegex(models, r"export 'db\.dart' show[^;]*\bTransaction\b")
        self.assertIn("models/transaction_display.dart", models)

        offenders = []
        for path in sorted((ROOT / "lib").rglob("*.dart")):
            parts = path.relative_to(ROOT / "lib").parts
            is_ui = (parts[0] == "shared" and len(parts) > 1 and parts[1] == "widgets") or (
                parts[0] == "features" and len(parts) > 2 and parts[2] == "presentation"
            )
            if not is_ui:
                continue
            source = path.read_text(encoding="utf-8")
            if "package:sesame_notes/data/db.dart" in source or re.search(
                r"\bdb\.Transaction\b", source
            ):
                offenders.append(path.relative_to(ROOT).as_posix())
        self.assertEqual([], offenders)

    def test_recurring_transaction_ui_uses_display_model_instead_of_drift_row(self) -> None:
        """周期账单 UI 只能消费展示模型，不得感知 Drift Row 或 Row Provider。"""
        models = (ROOT / "lib/data/models.dart").read_text(encoding="utf-8")
        self.assertNotRegex(models, r"(?m)^\s{8}RecurringTransaction,$")
        self.assertIn("models/recurring_transaction_display.dart", models)

        offenders = []
        recurring_row = re.compile(r"(?<!Display)\bRecurringTransaction\b")
        row_provider = re.compile(
            r"ref\s*\.\s*(?:read|watch|listen|invalidate)\s*\(\s*"
            r"allRecurringTransactionsProvider"
        )
        for path in sorted((ROOT / "lib").rglob("*.dart")):
            parts = path.relative_to(ROOT / "lib").parts
            is_ui = (parts[0] == "shared" and len(parts) > 1 and parts[1] == "widgets") or (
                parts[0] == "features" and len(parts) > 2 and parts[2] == "presentation"
            )
            if is_ui:
                source = path.read_text(encoding="utf-8")
                if recurring_row.search(source) or row_provider.search(source):
                    offenders.append(path.relative_to(ROOT).as_posix())
        self.assertEqual([], offenders)

    def test_transaction_metadata_ui_uses_display_models_instead_of_drift_rows(self) -> None:
        """交易分摊与编辑历史只能以展示模型进入 UI。"""
        models = (ROOT / "lib/data/models.dart").read_text(encoding="utf-8")
        self.assertNotRegex(
            models,
            r"\b(?:RecordEditHistory|TransactionSplit)\b",
        )
        self.assertIn("models/transaction_metadata_display.dart", models)

        offenders = []
        row_types = re.compile(r"(?<!Display)\b(?:RecordEditHistory|TransactionSplit)\b")
        for path in sorted((ROOT / "lib").rglob("*.dart")):
            parts = path.relative_to(ROOT / "lib").parts
            is_ui = (parts[0] == "shared" and len(parts) > 1 and parts[1] == "widgets") or (
                parts[0] == "features" and len(parts) > 2 and parts[2] == "presentation"
            )
            if is_ui and row_types.search(path.read_text(encoding="utf-8")):
                offenders.append(path.relative_to(ROOT).as_posix())
        self.assertEqual([], offenders)

    def test_ledger_ui_does_not_import_core_api(self) -> None:
        """账本页面和成员组件只提交用例意图，不得直接编排 Core API。"""
        paths = (
            ROOT / "lib/features/ledgers/presentation/join_shared_ledger_page.dart",
            ROOT / "lib/features/ledgers/presentation/ledger_edit_page.dart",
            ROOT
            / "lib/features/ledgers/presentation/widgets/member_management_section.dart",
        )
        offenders = [
            path.relative_to(ROOT).as_posix()
            for path in paths
            if re.search(
                r"(?m)^import 'package:sesame_notes/core/api/",
                path.read_text(encoding="utf-8"),
            )
        ]
        self.assertEqual([], offenders)

    def test_cloud_backup_ui_only_uses_application_models_and_actions(self) -> None:
        """云备份页面不得感知数据库 Row、Core API 或基础设施服务。"""
        paths = (
            ROOT / "lib/features/settings/presentation/cloud_service_page.dart",
            ROOT / "lib/features/settings/presentation/cloud_backup_config_page.dart",
        )
        forbidden = (
            "package:sesame_notes/core/api/",
            "package:sesame_notes/data/db.dart",
            "package:sesame_notes/features/settings/infrastructure/",
            "package:sesame_cloud_backup/",
        )
        offenders = [
            f"{path.relative_to(ROOT).as_posix()}: {pattern}"
            for path in paths
            for pattern in forbidden
            if pattern in path.read_text(encoding="utf-8")
        ]
        self.assertEqual([], offenders)

    def test_detail_import_ui_does_not_import_infrastructure(self) -> None:
        """明细导入页面只提交文件读取与解析意图，不得装配基础设施解析器。"""
        paths = (
            ROOT / "lib/features/settings/presentation/detail_import_export_page.dart",
            ROOT / "lib/features/settings/presentation/import_confirm_page.dart",
        )
        offenders = [
            path.relative_to(ROOT).as_posix()
            for path in paths
            if "package:sesame_notes/features/settings/infrastructure/"
            in path.read_text(encoding="utf-8")
        ]
        self.assertEqual([], offenders)

    def test_detail_export_infrastructure_is_ui_agnostic(self) -> None:
        """明细导出服务只处理数据与文件，不得反向依赖 Flutter 展示上下文。"""
        source = (
            ROOT / "lib/features/settings/infrastructure/detail_export_service.dart"
        ).read_text(encoding="utf-8")
        for forbidden in (
            "package:flutter/material.dart",
            "package:sesame_notes/l10n/",
            "package:sesame_notes/shared/presentation/",
            "BuildContext",
        ):
            with self.subTest(forbidden=forbidden):
                self.assertNotIn(forbidden, source)

    def test_backup_restore_ui_only_uses_application_state(self) -> None:
        """备份恢复页只渲染 application 状态，不得感知文件与恢复基础设施类型。"""
        source = (
            ROOT / "lib/features/settings/presentation/restore_backup_page.dart"
        ).read_text(encoding="utf-8")
        self.assertNotIn(
            "package:sesame_notes/features/settings/infrastructure/", source
        )
        for row_type in (
            "LocalBackupFile",
            "RecoveryItem",
            "RecoveryDecision",
            "BackupApplyEntry",
        ):
            with self.subTest(row_type=row_type):
                self.assertNotRegex(source, rf"\b{row_type}\b")

    def test_auth_ui_does_not_import_core_api_or_storage(self) -> None:
        """认证页面只提交 application 意图，不得直接编排 API 与账号缓存。"""
        auth_ui = ROOT / "lib/features/auth/presentation"
        forbidden = (
            "package:sesame_notes/core/api/",
            "package:sesame_notes/core/storage/",
        )
        offenders = [
            f"{path.relative_to(ROOT).as_posix()}: {pattern}"
            for path in sorted(auth_ui.glob("*.dart"))
            for pattern in forbidden
            if pattern in path.read_text(encoding="utf-8")
        ]
        self.assertEqual([], offenders)

    def test_app_lock_settings_only_uses_application_facade(self) -> None:
        """应用锁页面不得绕过可替换的 application 门面调用静态服务。"""
        source = (
            ROOT / "lib/features/settings/presentation/app_lock_settings_page.dart"
        ).read_text(encoding="utf-8")
        self.assertNotIn(
            "package:sesame_notes/features/auth/infrastructure/", source
        )
        self.assertNotIn("AppLockService.", source)

    def test_noop_post_processor_is_removed(self) -> None:
        """数据变更信号已由数据库监听驱动，不得保留只写日志的后处理门面。"""
        self.assertFalse((ROOT / "lib/providers/core/post_processor.dart").exists())
        offenders = [
            path.relative_to(ROOT).as_posix()
            for path in (ROOT / "lib").rglob("*.dart")
            if "PostProcessor" in path.read_text(encoding="utf-8")
        ]
        self.assertEqual([], offenders)

    def test_feature_domain_directories_stay_pure(self) -> None:
        """features/*/domain 只放纯规则与值对象。

        基础设施服务（文件系统、Drift、平台插件、仓储）与用例编排不属于
        domain，一旦混入，分层规则就无法形成有效门禁，因此直接锁死导入面。
        """
        forbidden = (
            "dart:io",
            "dart:isolate",
            "package:drift/",
            "package:sqlite3/",
            "package:path_provider/",
            "package:shared_preferences/",
            "package:flutter_secure_storage/",
            "package:file_picker/",
            "data/db.dart",
            "data/repositories/",
            "/application/",
            "/providers/",
            "package:sesame_cloud_backup",
        )
        offenders = []
        for domain in sorted((ROOT / "lib" / "features").glob("*/domain")):
            for path in sorted(domain.rglob("*.dart")):
                source = path.read_text(encoding="utf-8")
                for pattern in forbidden:
                    if pattern in source:
                        offenders.append(
                            f"{path.relative_to(ROOT).as_posix()} -> {pattern}"
                        )
                        break

        self.assertEqual([], offenders)

    def test_backup_adapters_expose_only_registration(self) -> None:
        """adapter 公共入口只保留注册函数，实现细节不得经 barrel 外泄。"""
        for package, register in (
            ("sesame_cloud_backup_s3", "registerS3Backend"),
            ("sesame_cloud_backup_webdav", "registerWebDavBackend"),
            ("sesame_cloud_backup_supabase", "registerSupabaseBackend"),
        ):
            entry = ROOT / "packages" / package / "lib" / f"{package}.dart"
            with self.subTest(package=package):
                source = entry.read_text(encoding="utf-8")
                self.assertIn(f"void {register}()", source)
                self.assertNotRegex(source, r"(?m)^export 'src/")

        # 主工程只经公共入口注册后端，不得绕过入口直连 adapter 内部实现。
        offenders = [
            path.relative_to(ROOT).as_posix()
            for path in (ROOT / "lib").rglob("*.dart")
            if re.search(
                r"package:sesame_cloud_backup_(?:s3|webdav|supabase)/src/",
                path.read_text(encoding="utf-8"),
            )
        ]
        self.assertEqual([], offenders)

    def test_backup_core_barrel_exposes_only_supported_contracts(self) -> None:
        """备份核心入口必须显式收窄，内部实现与序列化助手不得外泄。"""
        source = (
            ROOT / "packages/sesame_cloud_backup/lib/sesame_cloud_backup.dart"
        ).read_text(encoding="utf-8")
        exports = re.findall(r"(?ms)^export 'src/[^']+'(?:\s+show\s+[^;]+)?;", source)

        self.assertTrue(exports)
        self.assertTrue(
            all(" show " in " ".join(statement.split()) for statement in exports)
        )
        for internal in (
            "NoopAuthService",
            "CloudSerializationException",
            "FlutterSecureCredentialStorage",
            "SharedPreferencesCredentialStorage",
            "encodeCloudConfig",
            "decodeCloudConfig",
        ):
            with self.subTest(internal=internal):
                self.assertNotIn(internal, source)

    def test_backup_core_keeps_no_database_or_realtime_contracts(self) -> None:
        """备份核心不得回潮无 App 消费者的 database/realtime 抽象。"""
        for relative_path in (
            "packages/sesame_cloud_backup/lib/src/core/database_service.dart",
            "packages/sesame_cloud_backup/lib/src/core/realtime_service.dart",
            "packages/sesame_cloud_backup_supabase/lib/src/supabase_database_service.dart",
            "packages/sesame_cloud_backup_supabase/lib/src/supabase_realtime_service.dart",
        ):
            with self.subTest(relative_path=relative_path):
                self.assertFalse((ROOT / relative_path).exists())

        offenders = [
            path.relative_to(ROOT).as_posix()
            for path in (ROOT / "packages").rglob("*.dart")
            if ".dart_tool" not in path.parts
            for residue in ("CloudDatabaseService", "CloudRealtimeService")
            if residue in path.read_text(encoding="utf-8")
        ]
        self.assertEqual([], offenders)

    def test_ios_project_uses_the_product_identifier_and_privacy_text(self) -> None:
        """iOS 工程必须与 Android 使用同一产品标识，并声明生物识别用途。"""
        info = ROOT / "ios/Runner/Info.plist"
        entitlements = ROOT / "ios/Runner/Runner.entitlements"
        project = ROOT / "ios/Runner.xcodeproj/project.pbxproj"

        self.assertTrue(info.is_file())
        self.assertTrue(entitlements.is_file())
        self.assertTrue(project.is_file())

        info_text = info.read_text(encoding="utf-8")
        entitlement_text = entitlements.read_text(encoding="utf-8")
        project_text = project.read_text(encoding="utf-8")
        self.assertIn("Sesame Notes", info_text)
        self.assertIn("NSFaceIDUsageDescription", info_text)
        self.assertIn("用于解锁受保护的记账数据", info_text)
        self.assertIn("keychain-access-groups", entitlement_text)
        self.assertIn("PRODUCT_BUNDLE_IDENTIFIER = com.sesame.notes;", project_text)

    def test_production_code_does_not_reference_the_legacy_update_repo(self) -> None:
        """新仓库未确定时，生产代码不得保留旧项目的更新地址。"""
        offenders = [
            path.relative_to(ROOT).as_posix()
            for path in (ROOT / "lib").rglob("*.dart")
            if "weilixiaozhi/Spitout" in path.read_text(encoding="utf-8")
        ]

        self.assertEqual([], offenders)

    def test_release_artifacts_use_sesame_notes_brand(self) -> None:
        """APK 文件名与发布上传路径必须使用 Sesame Notes 品牌。"""
        workflow = (ROOT / ".github/workflows/release.yml").read_text(
            encoding="utf-8"
        )

        self.assertIn('APP_NAME: "Sesame-Notes"', workflow)
        self.assertNotIn("Spitout", workflow)
        self.assertEqual(3, workflow.count("${{ env.APP_NAME }}-*.apk"))

    def test_release_requires_production_signing_credentials(self) -> None:
        """缺少正式签名配置时必须中止发布，禁止生成 debug 签名产物。"""
        workflow = (ROOT / ".github/workflows/release.yml").read_text(
            encoding="utf-8"
        )
        gradle = (ROOT / "android/app/build.gradle").read_text(encoding="utf-8")

        self.assertNotIn("临时 debug keystore", workflow)
        self.assertNotIn("ci-debug.keystore", gradle)
        self.assertNotIn("androiddebugkey", gradle)
        self.assertIn("GradleException", gradle)

        for secret in (
            "KEYSTORE_BASE64",
            "KEYSTORE_PASSWORD",
            "KEY_ALIAS",
            "KEY_PASSWORD",
        ):
            with self.subTest(secret=secret):
                self.assertIn(f'[[ -n "${{{secret}:-}}" ]]', workflow)

        signing_examples = (
            ROOT / "android/key.properties.sample",
            ROOT / "scripts/android_keystore/README.md",
            ROOT / "scripts/android_keystore/generate_android_keystore.ps1",
        )
        offenders = [
            path.relative_to(ROOT).as_posix()
            for path in signing_examples
            if "spitout" in path.read_text(encoding="utf-8").lower()
        ]
        self.assertEqual([], offenders)

        signing_sample = signing_examples[0].read_text(encoding="utf-8")
        self.assertIn("storeFile=release.keystore", signing_sample)

    def test_android_does_not_request_broad_storage_access(self) -> None:
        """导入导出必须依赖系统选择器或分享，不得申请全盘文件权限。"""
        manifest = (ROOT / "android/app/src/main/AndroidManifest.xml").read_text(
            encoding="utf-8"
        )
        for residue in (
            "MANAGE_EXTERNAL_STORAGE",
            "WRITE_EXTERNAL_STORAGE",
            "requestLegacyExternalStorage",
        ):
            with self.subTest(residue=residue):
                self.assertNotIn(residue, manifest)

        pubspec = (ROOT / "pubspec.yaml").read_text(encoding="utf-8")
        self.assertNotRegex(pubspec, r"(?m)^\s*permission_handler:")

        removed_paths = (
            "lib/services/system/public_export_dir_service.dart",
            "lib/providers/import_export/public_export_dir_providers.dart",
            "lib/shared/widgets/storage_permission_helper.dart",
            "test/services/system/public_export_dir_service_test.dart",
            "test/app/storage_permission_helper_test.dart",
        )
        for path in removed_paths:
            with self.subTest(path=path):
                self.assertFalse((ROOT / path).exists())

        production_residues = (
            "Permission.manageExternalStorage",
            "requestAllFilesAccessProvider",
            "allFilesAccessCheckerProvider",
            "storagePermissionTitle",
            "localBackupOldLink",
        )
        sources = [
            path.read_text(encoding="utf-8")
            for path in (ROOT / "lib").rglob("*.dart")
        ]
        for residue in production_residues:
            with self.subTest(residue=residue):
                self.assertFalse(any(residue in source for source in sources))

        for export_page in (
            "lib/features/settings/presentation/detail_export_page.dart",
            "lib/features/settings/presentation/config_import_export_page.dart",
        ):
            with self.subTest(export_page=export_page):
                source = (ROOT / export_page).read_text(encoding="utf-8")
                self.assertIn("SharePlus.instance.share", source)

    def test_android_notifications_use_one_minimal_scheduler(self) -> None:
        """Android 提醒只使用通知插件及其必需权限和接收器。"""
        manifest = (ROOT / "android/app/src/main/AndroidManifest.xml").read_text(
            encoding="utf-8"
        )
        for permission in (
            "POST_NOTIFICATIONS",
            "SCHEDULE_EXACT_ALARM",
            "RECEIVE_BOOT_COMPLETED",
            "VIBRATE",
        ):
            with self.subTest(permission=permission):
                self.assertIn(f"android.permission.{permission}", manifest)

        for permission in (
            "WAKE_LOCK",
            "FOREGROUND_SERVICE",
            "USE_EXACT_ALARM",
            "REQUEST_IGNORE_BATTERY_OPTIMIZATIONS",
        ):
            with self.subTest(permission=permission):
                self.assertNotIn(f"android.permission.{permission}", manifest)

        self.assertIn(
            "com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver",
            manifest,
        )
        self.assertIn(
            "com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver",
            manifest,
        )

        removed_receivers = (
            "android/app/src/main/kotlin/com/sesame/notes/NotificationReceiver.kt",
            "android/app/src/main/kotlin/com/sesame/notes/NotificationClickReceiver.kt",
        )
        for path in removed_receivers:
            with self.subTest(path=path):
                self.assertFalse((ROOT / path).exists())

        dart_source = (
            ROOT / "lib/shared/services/notification/notification_android.dart"
        ).read_text(encoding="utf-8")
        native_source = (
            ROOT
            / "android/app/src/main/kotlin/com/sesame/notes/MainActivity.kt"
        ).read_text(encoding="utf-8")
        for residue in (
            "_scheduleBackupReminders",
            "_scheduleAlarmManagerBackup",
            "requestIgnoreBatteryOptimizations",
        ):
            with self.subTest(residue=residue):
                self.assertNotIn(residue, dart_source + native_source)

        self.assertNotIn("NotificationReceiver", native_source)
        self.assertNotIn("testDirectNotification", native_source)
        self.assertNotIn("fullScreenIntent: true", dart_source)

    def test_android_does_not_keep_the_legacy_apk_file_provider(self) -> None:
        """应用不得声明专用 APK 文件提供器。"""
        manifest = (ROOT / "android/app/src/main/AndroidManifest.xml").read_text(
            encoding="utf-8"
        )
        proguard = (ROOT / "android/app/proguard-rules.pro").read_text(
            encoding="utf-8"
        )

        self.assertNotIn("${applicationId}.fileprovider", manifest)
        self.assertNotIn("@xml/file_paths", manifest)
        self.assertNotIn("FileProvider", proguard)
        self.assertFalse((ROOT / "android/app/src/main/res/xml/file_paths.xml").exists())

    def test_v1_shared_ledger_invites_are_code_only(self) -> None:
        """v1 邀请只分享邀请码，不展示或复制未冻结域名的链接。"""
        source = (
            ROOT
            / "lib/features/ledgers/presentation/widgets/member_management_section.dart"
        ).read_text(encoding="utf-8")
        for residue in (
            "invite.shareUrl",
            "_copyInviteLink",
            "sharedInviteCopyLink",
            "sharedInviteShareLink",
        ):
            with self.subTest(residue=residue):
                self.assertNotIn(residue, source)

        localized_brands = {
            "app_en.arb": "Sesame Notes",
            "app_zh.arb": "芝麻记",
            "app_zh_TW.arb": "芝麻記",
        }
        for filename, brand in localized_brands.items():
            messages = json.loads(
                (ROOT / "lib/l10n" / filename).read_text(encoding="utf-8")
            )
            with self.subTest(filename=filename):
                self.assertNotIn("sharedInviteCopyLink", messages)
                self.assertNotIn("sharedInviteShareLink", messages)
                self.assertIn("sharedInviteShareCode", messages)
                copy = " ".join(
                    messages[key]
                    for key in (
                        "sharedJoinPageSubtitle",
                        "sharedJoinEnterCodeHint",
                        "sharedInviteInstruction",
                        "sharedInviteShareText",
                    )
                )
                self.assertNotRegex(copy, r"(?i)spitout|short link|\blink\b|短链|链接|連結")
                self.assertIn(brand, copy)

    def test_readme_documents_the_current_sesame_notes_workflow(self) -> None:
        """README 必须使用新项目标题并覆盖当前可执行的开发入口。"""
        readme = (ROOT / "README.md").read_text(encoding="utf-8")

        self.assertEqual("# Sesame Notes Mobile", readme.splitlines()[0])
        self.assertNotIn("weilixiaozhi/Spitout", readme)
        for required_text in (
            "Flutter 3.44.6",
            "Dart 3.12.2",
            "flutter pub get",
            "flutter run --flavor dev",
            "dart format --output=none --set-exit-if-changed .",
            "flutter analyze --no-pub",
            "flutter test --test-randomize-ordering-seed=random",
            "flutter build apk --debug --flavor dev",
            "OpenAPI",
            "iOS",
        ):
            with self.subTest(required_text=required_text):
                self.assertIn(required_text, readme)

    def test_root_widget_uses_sesame_notes_brand(self) -> None:
        """应用根 Widget 及启动入口不得继续使用旧品牌类名。"""
        app_source = (ROOT / "lib/shell/app_shell.dart").read_text(encoding="utf-8")
        main_source = (ROOT / "lib/main.dart").read_text(encoding="utf-8")

        self.assertNotRegex(app_source, r"\b_?SpitoutApp\b")
        self.assertIn(
            "class SesameNotesApp extends ConsumerStatefulWidget", app_source
        )
        self.assertIn("return const SesameNotesApp();", main_source)

    def test_localized_app_titles_use_sesame_notes_brand(self) -> None:
        """应用内标题与 Android 英文启动器名称必须展示新品牌。"""
        expected_titles = {
            "app_en.arb": "Sesame Notes",
            "app_zh.arb": "芝麻记",
            "app_zh_TW.arb": "芝麻記",
        }
        for filename, expected_title in expected_titles.items():
            with self.subTest(filename=filename):
                messages = json.loads(
                    (ROOT / "lib/l10n" / filename).read_text(encoding="utf-8")
                )
                self.assertEqual(expected_title, messages["appTitle"])

        android_titles = {
            "android/app/src/main/res/values-en/strings.xml": "Sesame Notes",
            "android/app/src/debug/res/values-en/strings.xml": "Sesame Notes Debug",
        }
        for relative_path, expected_title in android_titles.items():
            with self.subTest(relative_path=relative_path):
                resources = (ROOT / relative_path).read_text(encoding="utf-8")
                self.assertIn(
                    f'<string name="app_name">{expected_title}</string>', resources
                )

    def test_generic_localized_copy_uses_sesame_notes_brand(self) -> None:
        """与旧云协议无关的通用提示和分享文案必须展示新品牌。"""
        localized_brands = {
            "app_en.arb": "Sesame Notes",
            "app_zh.arb": "芝麻记",
            "app_zh_TW.arb": "芝麻記",
        }
        generic_keys = (
            "reminderAndroidInstructions",
            "logCenterExportSubject",
            "configExportShareSubject",
            "appLockBiometricReason",
        )

        for filename, brand in localized_brands.items():
            messages = json.loads(
                (ROOT / "lib/l10n" / filename).read_text(encoding="utf-8")
            )
            for key in generic_keys:
                with self.subTest(filename=filename, key=key):
                    self.assertNotIn("Spitout", messages[key])
                    self.assertIn(brand, messages[key])

    def test_bottom_bar_uses_brand_neutral_name(self) -> None:
        """通用底部栏及其测试文件不得继续携带旧项目品牌。"""
        offenders = [
            path.relative_to(ROOT).as_posix()
            for source_root in ("lib", "test")
            for path in (ROOT / source_root).rglob("*.dart")
            if re.search(r"\bSpitoutBottomBar\b", path.read_text(encoding="utf-8"))
        ]

        self.assertEqual([], offenders)
        self.assertTrue((ROOT / "test/app/app_bottom_bar_test.dart").is_file())
        self.assertFalse((ROOT / "test/app/spitout_bottom_bar_test.dart").exists())

    def test_core_design_system_uses_brand_neutral_names(self) -> None:
        """通用设计系统类型、测试文件名与使用文档必须统一使用 App 前缀。"""
        renames = {
            "SpitoutDimens": "AppDimens",
            "SpitoutColors": "AppColors",
            "SpitoutTokens": "AppTokens",
            "SpitoutTextTokens": "AppTextTokens",
            "SpitoutTypography": "AppTypography",
            "SpitoutShadows": "AppShadows",
            "SpitoutChartTokens": "AppChartTokens",
            "SpitoutTheme": "AppTheme",
        }
        sources = [
            (path, path.read_text(encoding="utf-8"))
            for source_root in ("lib", "test")
            for path in (ROOT / source_root).rglob("*.dart")
        ]
        design_doc = ROOT / "docs/DESIGN_TOKENS.md"
        design_doc_content = design_doc.read_text(encoding="utf-8")
        sources.append((design_doc, design_doc_content))

        for old_name, new_name in renames.items():
            with self.subTest(old_name=old_name):
                offenders = [
                    path.relative_to(ROOT).as_posix()
                    for path, source in sources
                    if re.search(rf"\b{old_name}\b", source)
                ]
                self.assertEqual([], offenders)
                self.assertTrue(
                    any(re.search(rf"\b{new_name}\b", source) for _, source in sources)
                )

        self.assertTrue((ROOT / "test/theme/app_theme_test.dart").is_file())
        self.assertTrue((ROOT / "test/theme/app_tokens_test.dart").is_file())
        self.assertFalse((ROOT / "test/theme/spitout_theme_test.dart").exists())
        self.assertFalse((ROOT / "test/theme/spitout_tokens_test.dart").exists())
        self.assertTrue(
            design_doc_content.startswith("# Sesame Notes Design Token 系统\n")
        )
        self.assertNotIn("Spitout", design_doc_content)

    def test_popup_menu_uses_brand_neutral_names(self) -> None:
        """通用弹出菜单类型、文件名与导出入口必须统一使用 App 前缀。"""
        renames = {
            "SpitoutMenuItemType": "AppMenuItemType",
            "SpitoutMenuItem": "AppMenuItem",
            "SpitoutPopupMenu": "AppPopupMenu",
        }
        sources = [
            (path, path.read_text(encoding="utf-8"))
            for source_root in ("lib", "test")
            for path in (ROOT / source_root).rglob("*.dart")
        ]

        for old_name, new_name in renames.items():
            with self.subTest(old_name=old_name):
                offenders = [
                    path.relative_to(ROOT).as_posix()
                    for path, source in sources
                    if re.search(rf"\b{old_name}\b", source)
                ]
                self.assertEqual([], offenders)
                self.assertTrue(
                    any(re.search(rf"\b{new_name}\b", source) for _, source in sources)
                )

        old_path = ROOT / "lib/shared/widgets/spitout_popup_menu.dart"
        new_path = ROOT / "lib/shared/widgets/app_popup_menu.dart"
        self.assertFalse(old_path.exists())
        self.assertTrue(new_path.is_file())

        exports = (ROOT / "lib/shared/widgets/widgets.dart").read_text(encoding="utf-8")
        self.assertNotIn("spitout_popup_menu.dart", exports)
        self.assertIn("export 'app_popup_menu.dart';", exports)

    def test_app_logo_uses_brand_neutral_names(self) -> None:
        """应用 Logo 类型、资产、生成工具与文档不得保留旧品牌名。"""
        icon_doc = ROOT / "docs/ICON_GENERATION.md"
        source_paths = [
            *(ROOT / "lib").rglob("*.dart"),
            *(ROOT / "test").rglob("*.dart"),
            ROOT / "pubspec.yaml",
            icon_doc,
            ROOT / "scripts/launcher_icons/rasterize_svg.dart",
            ROOT / "scripts/launcher_icons/README.md",
        ]
        sources = [
            (path, path.read_text(encoding="utf-8")) for path in source_paths
        ]

        for residue in ("SpitoutIcon", "spitout_icon", "ic_launcher_spitout"):
            with self.subTest(residue=residue):
                offenders = [
                    path.relative_to(ROOT).as_posix()
                    for path, source in sources
                    if residue in source
                ]
                self.assertEqual([], offenders)

        old_widget = ROOT / "lib/shared/widgets/spitout_icon.dart"
        new_widget = ROOT / "lib/shared/widgets/app_logo.dart"
        old_asset = ROOT / "assets/brand/ic_launcher_spitout.svg"
        new_asset = ROOT / "assets/app_logo.svg"
        self.assertFalse(old_widget.exists())
        self.assertTrue(new_widget.is_file())
        self.assertFalse(old_asset.exists())
        self.assertTrue(new_asset.is_file())

        logo_source = new_widget.read_text(encoding="utf-8")
        self.assertRegex(logo_source, r"\bclass AppLogo\b")
        self.assertIn("assets/app_logo.svg", logo_source)

        pubspec = (ROOT / "pubspec.yaml").read_text(encoding="utf-8")
        self.assertIn("- assets/app_logo.svg", pubspec)
        exports = (ROOT / "lib/shared/widgets/widgets.dart").read_text(encoding="utf-8")
        self.assertIn("export 'app_logo.dart';", exports)
        self.assertNotIn("Spitout", icon_doc.read_text(encoding="utf-8"))

    def test_exported_file_names_use_sesame_notes_prefixes(self) -> None:
        """导出、配置和备份文件名必须脱离旧品牌前缀。"""
        source_paths = [
            *(ROOT / "lib").rglob("*.dart"),
            *(ROOT / "lib/l10n").glob("*.arb"),
        ]
        sources = [
            (path, path.read_text(encoding="utf-8")) for path in source_paths
        ]

        for prefix in (
            "spitout_backup_",
            "spitout_emergency_",
            "spitout_config_",
            "spitout_$ts.csv",
            "spitout_timestamp.csv",
        ):
            with self.subTest(prefix=prefix):
                offenders = [
                    path.relative_to(ROOT).as_posix()
                    for path, source in sources
                    if prefix in source
                ]
                self.assertEqual([], offenders)

        for prefix in (
            "sesame_notes_backup_",
            "sesame_notes_emergency_",
            "sesame_notes_config_",
            "sesame_notes_$ts.csv",
            "sesame_notes_timestamp.csv",
        ):
            with self.subTest(prefix=prefix):
                self.assertTrue(any(prefix in source for _, source in sources))

    def test_packages_and_ignore_rules_have_no_legacy_product_residue(self) -> None:
        """第三方备份包仅可保留明确的旧项目许可证来源说明。"""
        permitted_attributions = {
            (
                "packages/sesame_cloud_backup_supabase/README.md",
                "This package is part of the Spitout project and uses the same license.",
            ),
            (
                "packages/sesame_cloud_backup_webdav/README.md",
                "This package is part of the Spitout project and uses the same license.",
            ),
        }
        package_paths = list((ROOT / "packages").rglob("*"))
        source_paths = [
            ROOT / ".gitignore",
            *(path for path in package_paths if path.is_file()),
        ]
        offenders = [
            path.relative_to(ROOT).as_posix()
            for path in package_paths
            if "spitout" in path.relative_to(ROOT).as_posix().lower()
        ]
        for path in source_paths:
            try:
                lines = path.read_text(encoding="utf-8").splitlines()
            except UnicodeDecodeError:
                continue

            relative_path = path.relative_to(ROOT).as_posix()
            for line_number, line in enumerate(lines, start=1):
                if "spitout" not in line.lower():
                    continue
                if (relative_path, line.strip()) in permitted_attributions:
                    continue
                offenders.append(f"{relative_path}:{line_number}")

        self.assertEqual([], offenders)

    def test_historical_maintenance_tools_are_removed(self) -> None:
        """生产应用不得保留孤儿清理或测试数据填充入口。"""
        removed_paths = (
            "lib/features/ledgers/maintenance/orphan_cleanup_page.dart",
            "lib/services/maintenance/orphan_cleaner.dart",
            "lib/services/maintenance/orphan_record.dart",
            "lib/services/maintenance/orphan_models.dart",
            "lib/services/maintenance/orphan_scanner.dart",
            "lib/services/maintenance/orphan_seeder.dart",
            "lib/services/maintenance/analytics_test_data_seeder.dart",
            "test/features/ledgers/maintenance/orphan_cleanup_page_test.dart",
            "test/maintenance/orphan_cleaner_test.dart",
            "test/maintenance/orphan_scanner_test.dart",
            "test/services/maintenance/orphan_maintenance_test.dart",
            "test/services/maintenance/analytics_test_data_seeder_test.dart",
        )
        for path in removed_paths:
            with self.subTest(path=path):
                self.assertFalse((ROOT / path).exists())

        production_sources = {
            path: (ROOT / path).read_text(encoding="utf-8")
            for path in (
                "lib/features/ledgers/presentation/home_page.dart",
                "lib/features/ledgers/presentation/mine_page.dart",
                "lib/providers/maintenance/maintenance_providers.dart",
            )
            if (ROOT / path).exists()
        }
        for residue in (
            "OrphanCleanupPage",
            "orphanScanReportProvider",
            "analyticsTestDataSeederProvider",
            "_onTapFillTestData",
        ):
            with self.subTest(residue=residue):
                offenders = [
                    path for path, source in production_sources.items() if residue in source
                ]
                self.assertEqual([], offenders)


if __name__ == "__main__":
    unittest.main()
