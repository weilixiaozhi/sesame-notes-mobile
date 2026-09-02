#!/usr/bin/env python3
"""静态依赖环检测（根工程与本地 package 的业务代码必须无环）。

规则：
- 扫描根工程 lib/ 与 packages/*/lib，排除 l10n 和生成文件；
- part 文件并入所属 library，不把「主库 ↔ part」误判为环；
- 存在任何非平凡强连通分量（SCC）即失败，并列出环内 library。
"""

import posixpath
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent.parent
EXCLUDE_REL_PREFIX = "l10n/"
IGNORE_SUFFIXES = (".g.dart", ".freezed.dart")

import_re = re.compile(r"^\s*(?:import|export)\s+'([^']+)'", re.MULTILINE)
part_re = re.compile(r"^\s*part\s+'([^']+)'", re.MULTILINE)
part_of_re = re.compile(r"^\s*part of\s+'([^']+)'", re.MULTILINE)
package_name_re = re.compile(r"(?m)^name:\s*([a-zA-Z0-9_]+)\s*$")


def discover_package_libs(root: Path = ROOT) -> dict[str, Path]:
    """发现根工程及 packages/* 下具名 Dart package 的 lib 目录。"""
    result: dict[str, Path] = {}
    for package_dir in (root, *sorted((root / "packages").glob("*"))):
        pubspec = package_dir / "pubspec.yaml"
        lib_dir = package_dir / "lib"
        if not pubspec.is_file() or not lib_dir.is_dir():
            continue
        match = package_name_re.search(pubspec.read_text(encoding="utf-8-sig"))
        if match is not None:
            result[match.group(1)] = lib_dir
    return result


def source_id(package: str, relative: str) -> str:
    return f"package:{package}/{relative}"


def split_source_id(identifier: str) -> tuple[str, str]:
    package, relative = identifier.removeprefix("package:").split("/", 1)
    return package, relative


def resolve_target(
    current_id: str,
    uri: str,
    package_libs: dict[str, Path],
) -> str | None:
    """把 package/相对 URI 解析为本地 library 的规范 id。"""
    current_package, current_rel = split_source_id(current_id)
    if uri.startswith("package:"):
        target = uri.removeprefix("package:")
        package = target.split("/", 1)[0]
        return uri if package in package_libs else None
    if uri.startswith("dart:"):
        return None
    base = posixpath.dirname(current_rel)
    return source_id(
        current_package,
        posixpath.normpath(posixpath.join(base, uri)),
    )


def build_graph(package_libs: dict[str, Path]) -> dict[str, set[str]]:
    """构建全部本地 package 的 library 依赖图。"""
    files: dict[str, Path] = {}
    for package, lib_dir in package_libs.items():
        for path in lib_dir.rglob("*.dart"):
            relative = path.relative_to(lib_dir).as_posix()
            if relative.startswith(EXCLUDE_REL_PREFIX) or path.name.endswith(
                IGNORE_SUFFIXES
            ):
                continue
            files[source_id(package, relative)] = path

    libraries = {
        identifier: path
        for identifier, path in files.items()
        if not part_of_re.search(path.read_text(encoding="utf-8"))
    }
    library_ids = set(libraries)

    # part 文件归属主库，后续以主库为图节点。
    part_to_library: dict[str, str] = {}
    for library_id, path in libraries.items():
        text = path.read_text(encoding="utf-8")
        for match in part_re.finditer(text):
            part_id = resolve_target(library_id, match.group(1), package_libs)
            if part_id in files:
                part_to_library[part_id] = library_id

    graph: dict[str, set[str]] = {identifier: set() for identifier in library_ids}
    for library_id, path in libraries.items():
        sources = [path] + [
            files[part_id]
            for part_id, owner in part_to_library.items()
            if owner == library_id
        ]
        for source in sources:
            for match in import_re.finditer(source.read_text(encoding="utf-8")):
                target = resolve_target(library_id, match.group(1), package_libs)
                if target is None:
                    continue
                owner = part_to_library.get(target, target)
                if owner in library_ids and owner != library_id:
                    graph[library_id].add(owner)
    return graph


def directory_node(package: str, relative: str) -> str:
    """把 library 的相对路径收缩为「package + lib 下第一层目录」节点。

    lib 根目录直属文件（如 main.dart）归入 ``<package>:<root>``，避免与任何
    目录组混在一起。
    """
    first = relative.split("/", 1)[0]
    if "." in first:
        return f"{package}:<root>"
    return f"{package}:{first}"


def contract_to_directories(graph: dict[str, set[str]]) -> dict[str, set[str]]:
    """把文件依赖图收缩为目录图，并剔除自环。

    剔除自环是刻意的：同一目录内部的互相引用（含基线豁免的
    ``data/models.dart`` ↔ ``data/db.dart`` 门面伪环）在目录粒度只是自环，
    既不是运行期循环，也不构成目录所有权问题，不应让门禁失败。
    """
    contracted: dict[str, set[str]] = {}
    for source, targets in graph.items():
        package, relative = split_source_id(source)
        src = directory_node(package, relative)
        contracted.setdefault(src, set())
        for target in targets:
            target_package, target_relative = split_source_id(target)
            dst = directory_node(target_package, target_relative)
            contracted.setdefault(dst, set())
            if src != dst:
                contracted[src].add(dst)
    return contracted


def find_cycles(graph: dict[str, set[str]]) -> list[list[str]]:
    """用 Tarjan SCC 返回所有非平凡依赖环。"""
    index = 0
    stack: list[str] = []
    on_stack: set[str] = set()
    indices: dict[str, int] = {}
    lowlink: dict[str, int] = {}
    cycles: list[list[str]] = []

    def strongconnect(node: str) -> None:
        nonlocal index
        indices[node] = index
        lowlink[node] = index
        index += 1
        stack.append(node)
        on_stack.add(node)
        for target in graph[node]:
            if target not in indices:
                strongconnect(target)
                lowlink[node] = min(lowlink[node], lowlink[target])
            elif target in on_stack:
                lowlink[node] = min(lowlink[node], indices[target])
        if lowlink[node] != indices[node]:
            return
        component = []
        while True:
            target = stack.pop()
            on_stack.remove(target)
            component.append(target)
            if target == node:
                break
        if len(component) > 1:
            cycles.append(sorted(component))

    for node in sorted(graph):
        if node not in indices:
            strongconnect(node)
    return sorted(cycles)


def main() -> int:
    package_libs = discover_package_libs()
    graph = build_graph(package_libs)
    if not graph:
        print("No source libraries found", file=sys.stderr)
        return 1
    cycles = find_cycles(graph)
    if cycles:
        print("Detected dependency cycles:", file=sys.stderr)
        for cycle in cycles:
            print("  " + " -> ".join(cycle), file=sys.stderr)
        return 1

    # 目录级门禁：文件级无环不代表目录所有权健康——目录之间仍可能形成
    # 双向依赖（如 features ↔ providers），这类回边会让分层逐步失效。
    directory_graph = contract_to_directories(graph)
    directory_cycles = find_cycles(directory_graph)
    if directory_cycles:
        print("Detected directory-level dependency cycles:", file=sys.stderr)
        for cycle in directory_cycles:
            print("  " + " -> ".join(cycle), file=sys.stderr)
        return 1

    print(
        f"OK: no file cycles across {len(graph)} libraries and no directory "
        f"cycles across {len(directory_graph)} directory groups in "
        f"{len(package_libs)} packages (l10n/generated excluded)"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
