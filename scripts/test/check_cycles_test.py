#!/usr/bin/env python3
"""依赖环检测脚本的指令解析回归测试。"""

import unittest
from pathlib import Path
from tempfile import TemporaryDirectory

import check_cycles


class DirectiveParsingTest(unittest.TestCase):
    """确保文件头与多条声明不会让依赖扫描漏边。"""

    def test_reads_imports_and_exports_from_every_line(self) -> None:
        """注释后的多条 import/export 都必须进入依赖图。"""
        source = """// 文件说明
import 'first.dart';
import 'second.dart';
export 'facade.dart';
"""

        self.assertEqual(
            ["first.dart", "second.dart", "facade.dart"],
            [match.group(1) for match in check_cycles.import_re.finditer(source)],
        )

    def test_reads_part_directives_after_headers(self) -> None:
        """library 注释后的 part 与 part of 必须被正确归并。"""
        library_source = """// 主库说明
part 'first_part.dart';
part 'second_part.dart';
"""
        part_source = """// 分片说明
part of 'owner.dart';
"""

        self.assertEqual(
            ["first_part.dart", "second_part.dart"],
            [match.group(1) for match in check_cycles.part_re.finditer(library_source)],
        )
        self.assertIsNotNone(check_cycles.part_of_re.search(part_source))

    def test_detects_core_to_adapter_cycle_across_package_roots(self) -> None:
        """根工程 Core 与 adapter 互相导入时必须形成跨包环并失败。"""
        with TemporaryDirectory() as temp:
            root = Path(temp)
            app_lib = root / "app" / "lib"
            adapter_lib = root / "adapter" / "lib"
            (app_lib / "core").mkdir(parents=True)
            adapter_lib.mkdir(parents=True)
            (app_lib / "core" / "api.dart").write_text(
                "import 'package:test_adapter/adapter.dart';\n",
                encoding="utf-8",
            )
            (adapter_lib / "adapter.dart").write_text(
                "import 'package:sesame_notes/core/api.dart';\n",
                encoding="utf-8",
            )

            graph = check_cycles.build_graph(
                {"sesame_notes": app_lib, "test_adapter": adapter_lib}
            )

            self.assertEqual(
                [[
                    "package:sesame_notes/core/api.dart",
                    "package:test_adapter/adapter.dart",
                ]],
                check_cycles.find_cycles(graph),
            )


class DirectoryContractionTest(unittest.TestCase):
    """目录图收缩：跨目录环必须检出，目录内自环必须豁免。"""

    def _graph(self, root: Path, sources: dict[str, str]) -> dict[str, set]:
        """在临时 lib 目录里按 ``相对路径 -> 源码`` 落文件并构建依赖图。"""
        lib = root / "app" / "lib"
        for relative, source in sources.items():
            target = lib / relative
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text(source, encoding="utf-8")
        return check_cycles.build_graph({"pkg": lib})

    def test_directory_node_puts_root_files_in_own_group(self) -> None:
        """lib 根直属文件归入 <root> 组，不与 features 等目录混在一起。"""
        self.assertEqual("pkg:<root>", check_cycles.directory_node("pkg", "main.dart"))
        self.assertEqual(
            "pkg:features",
            check_cycles.directory_node("pkg", "features/auth/page.dart"),
        )

    def test_directory_contraction_detects_cross_directory_cycle(self) -> None:
        """core → data → core 的跨目录回边必须形成目录 SCC。"""
        with TemporaryDirectory() as temp:
            graph = self._graph(
                Path(temp),
                {
                    "core/a.dart": "import 'package:pkg/data/b.dart';\n",
                    "data/b.dart": "import 'package:pkg/core/c.dart';\n",
                    "core/c.dart": "// leaf\n",
                },
            )

            self.assertEqual(
                [["pkg:core", "pkg:data"]],
                check_cycles.find_cycles(check_cycles.contract_to_directories(graph)),
            )

    def test_intra_directory_cycles_are_ignored(self) -> None:
        """目录内互相引用（含基线豁免的门面伪环）收缩后只是自环，不算环。"""
        with TemporaryDirectory() as temp:
            graph = self._graph(
                Path(temp),
                {
                    "data/models.dart": "import 'package:pkg/data/db.dart';\n",
                    "data/db.dart": "import 'package:pkg/data/models.dart';\n",
                },
            )

            self.assertEqual(
                [],
                check_cycles.find_cycles(check_cycles.contract_to_directories(graph)),
            )

    def test_root_level_files_form_own_group(self) -> None:
        """main.dart 与 features 互相导入时按 <root> ↔ features 成环。"""
        with TemporaryDirectory() as temp:
            graph = self._graph(
                Path(temp),
                {
                    "main.dart": "import 'package:pkg/features/page.dart';\n",
                    "features/page.dart": "import 'package:pkg/main.dart';\n",
                },
            )

            self.assertEqual(
                [["pkg:<root>", "pkg:features"]],
                check_cycles.find_cycles(check_cycles.contract_to_directories(graph)),
            )

    def test_real_project_has_no_directory_cycles(self) -> None:
        """真实仓库（含 packages/*）的目录图必须是 DAG。"""
        graph = check_cycles.build_graph(check_cycles.discover_package_libs())

        self.assertEqual(
            [],
            check_cycles.find_cycles(check_cycles.contract_to_directories(graph)),
        )


if __name__ == "__main__":
    unittest.main()
