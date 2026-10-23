"""从实际 APK 和 pubspec 版本生成公开更新元数据，不引入第三方依赖。"""

import argparse
import hashlib
import json
import re
from pathlib import Path


def create_manifest(apk: Path, version: str, repository: str, notes: str) -> dict:
    match = re.fullmatch(r"(\d+\.\d+\.\d+)\+([1-9]\d*)", version)
    if not match or not re.fullmatch(r"[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+", repository):
        raise ValueError("无效的版本号或 GitHub 仓库")
    name, build = match.groups()
    expected_name = f"Sesame-Notes-prod-v{name}.apk"
    if apk.name != expected_name or not apk.is_file() or apk.stat().st_size == 0:
        raise ValueError("缺少对应版本的 APK")
    with apk.open("rb") as stream:
        digest = hashlib.file_digest(stream, "sha256").hexdigest()
    return {
        "version": name,
        "buildNumber": int(build),
        "packageName": "com.sesame.notes",
        "abi": "arm64-v8a",
        "url": f"https://github.com/{repository}/releases/download/v{name}/{apk.name}",
        "size": apk.stat().st_size,
        "sha256": digest,
        "notes": notes,
    }


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--apk", required=True, type=Path)
    parser.add_argument("--version", required=True)
    parser.add_argument("--repository", required=True)
    parser.add_argument("--notes", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()
    manifest = create_manifest(
        args.apk, args.version, args.repository, args.notes.read_text(encoding="utf-8")
    )
    args.output.write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
