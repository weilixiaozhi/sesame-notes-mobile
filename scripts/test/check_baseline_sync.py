#!/usr/bin/env python3
"""架构基线双仓一致性门禁。

规则：
- docs/TECHNICAL-ARCHITECTURE-BASELINE.md 必须与 docs/TECHNICAL-ARCHITECTURE-BASELINE.sha256
  记录的权威副本哈希一致；CI 只 checkout 单个仓库，故以该清单作为对照，不符即阻断合并。
- 传入 --peer <目录> 时，额外与该 checkout 的基线正文逐字比对。
"""

import argparse
import hashlib
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent.parent
BODY_RELATIVE_PATH = "docs/TECHNICAL-ARCHITECTURE-BASELINE.md"
MANIFEST_RELATIVE_PATH = "docs/TECHNICAL-ARCHITECTURE-BASELINE.sha256"
HASH_RE = re.compile(r"^[0-9a-f]{64}$")


def sha256_of(path: Path) -> str:
    """计算文件的 SHA-256，返回小写十六进制串。"""
    return hashlib.sha256(path.read_bytes()).hexdigest()


def read_manifest_hash(path: Path) -> str:
    """解析权威副本哈希清单；格式与 `sha256sum -c` 兼容，即 `<hash>  <路径>`。"""
    tokens = path.read_text(encoding="utf-8").strip().split()
    candidate = tokens[0].lower() if tokens else ""
    if not HASH_RE.match(candidate):
        raise ValueError(f"权威副本哈希清单格式非法，应为 64 位 SHA-256：{path}")
    return candidate


def verify(root: Path = ROOT, peer_root: Path | None = None) -> tuple[str | None, list[str]]:
    """校验正文与权威副本哈希清单，并在给出 peer_root 时逐字比对两份正文。"""
    body_path = root / BODY_RELATIVE_PATH
    if not body_path.is_file():
        return None, [f"基线正文缺失：{body_path}"]

    body_hash = sha256_of(body_path)
    errors: list[str] = []
    manifest_path = root / MANIFEST_RELATIVE_PATH

    if not manifest_path.is_file():
        errors.append(
            f"权威副本哈希清单缺失：{MANIFEST_RELATIVE_PATH}（当前正文 SHA-256 为 {body_hash}）"
        )
    else:
        expected = read_manifest_hash(manifest_path)
        if expected != body_hash:
            errors.append(
                f"正文与权威副本哈希清单不一致：清单记录 {expected}，实际 {body_hash}；"
                f"改动基线正文必须同步更新两个仓库的 {MANIFEST_RELATIVE_PATH}"
            )

    if peer_root is not None:
        peer_path = peer_root / BODY_RELATIVE_PATH
        if not peer_path.is_file():
            errors.append(f"对端 checkout 基线正文缺失：{peer_path}")
        else:
            peer_hash = sha256_of(peer_path)
            if peer_hash != body_hash:
                errors.append(
                    f"两份基线正文不是逐字一致：本仓 {body_hash}（{body_path}），"
                    f"对端 {peer_hash}（{peer_path}）"
                )

    return body_hash, errors


def main() -> int:
    # Windows 控制台默认 cp1252，输出中文诊断会抛 UnicodeEncodeError 并让门禁误报失败。
    sys.stdout.reconfigure(encoding="utf-8")
    sys.stderr.reconfigure(encoding="utf-8")

    parser = argparse.ArgumentParser(description="校验架构基线在双仓逐字一致")
    parser.add_argument("--peer", type=Path, default=None, help="另一仓 checkout 根目录")
    args = parser.parse_args()

    body_hash, errors = verify(ROOT, args.peer)
    if errors:
        # 不使用 emoji：Windows 控制台默认 cp1252 无法编码，会让门禁误报为失败。
        print(f"FAIL: 架构基线双仓一致性门禁失败（{len(errors)} 项）：", file=sys.stderr)
        for item in errors:
            print(f"  - {item}", file=sys.stderr)
        return 1
    print(f"OK: 架构基线双仓一致性校验通过（SHA-256 {body_hash}）")
    return 0


if __name__ == "__main__":
    sys.exit(main())
