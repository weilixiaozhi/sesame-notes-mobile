"""从离线动作资料生成同步可用的校验表，不在导入或仓库层异步读取 Flutter 资源。"""

import json
from pathlib import Path

root = Path(__file__).resolve().parents[2]
source = json.loads((root / 'assets/fitness/exercises.json').read_text(encoding='utf-8'))
rows = source['exercises']
if len({row['id'] for row in rows}) != len(rows):
    raise ValueError('Duplicate exercise identity')
lines = [
    '// GENERATED CODE - DO NOT MODIFY BY HAND.',
    '// 来源 assets/fitness/exercises.json；运行 python scripts/fitness/generate_catalog_registry.py 后 dart format。',
    'const fitnessCatalogRegistry = <String>{',
]
for row in rows:
    lines.append(f"  '{row['id']}',")
lines.append('};')
(root / 'lib/data/models/fitness_catalog_registry.dart').write_text('\n'.join(lines) + '\n', encoding='utf-8')
