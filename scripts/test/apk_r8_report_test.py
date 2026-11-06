"""验证R8报告同时保护历史通知字段和当前版本新增入口。"""

import copy
import importlib.util
import json
import sys
from pathlib import Path
from tempfile import TemporaryDirectory
from types import SimpleNamespace
import unittest
from unittest.mock import patch
import zipfile

ROOT = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location('apk_r8_report', ROOT / 'scripts/audit/apk_r8_report.py')
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)
MODEL = MODULE.MODEL_PREFIX + 'NotificationDetails'


class R8HistoricalRequirementsTest(unittest.TestCase):
    """在真实报告流程中注入模型映射，二进制解析器使用固定小夹具。"""

    def setUp(self):
        """只在本仓Temp创建独占输入，测试后清理本次目录。"""
        (ROOT / 'Temp').mkdir(exist_ok=True)
        self.temporary = TemporaryDirectory(prefix='r8-requirements-', dir=ROOT / 'Temp')
        self.directory = Path(self.temporary.name)
        if not self.directory.resolve().is_relative_to((ROOT / 'Temp').resolve()):
            raise RuntimeError('R8回归目录越界')
        self.addCleanup(self.temporary.cleanup)
        self.apk = self.directory / 'fixture.apk'
        with zipfile.ZipFile(self.apk, 'w') as archive:
            archive.writestr('classes.dex', b'fixture')
        self.engine = self.directory / 'engine.jar'
        self.engine.write_bytes(b'fixture')
        for name in ('mapping', 'seeds', 'usage', 'configuration'):
            (self.directory / f'{name}.txt').write_text('', encoding='utf-8')

    def run_report(self, *, renamed_field=False, renamed_class=False, baseline_fixed=True):
        """仅替换底层解码结果，报告本身必须执行真实的基线合并与名称检查。"""
        target = 'renamed.Model' if renamed_class else MODEL
        field_target = 'obfuscated' if renamed_field else 'newField'
        definitions = {
            'Engine': {'fields': set(), 'methods': set()},
            'Registrant': {'fields': set(), 'methods': {'registerWith'}},
            target: {'fields': {'legacy', field_target}, 'methods': set()},
        }
        mapping = {'Engine': 'Engine', 'Registrant': 'Registrant', MODEL: target}
        members = {MODEL: {'fields': {'legacy': {'legacy'}, 'newField': {field_target}}}}
        baseline = self.directory / 'baseline.json'
        baseline.write_text(json.dumps({
            'format': 'sesame-notes.apk-r8-report.v1',
            'requirements': {MODEL: {'fixed_class_name': baseline_fixed, 'fields': ['legacy'], 'methods': []}},
            'artifacts': {'apk': MODULE.artifact(self.apk), 'engine_jar': MODULE.artifact(self.engine)},
            'dex': {'raw_bytes': 7, 'zip_bytes': 7},
            'r8': {'seeds': {'classes': 0, 'members': 0}},
        }), encoding='utf-8')
        arguments = SimpleNamespace(
            apk=self.apk, mapping_dir=self.directory, engine_jar=self.engine, baseline=baseline,
        )
        with (
            patch.object(MODULE, 'APP_ENTRIES', ()),
            patch.object(MODULE, 'REGISTRANT', 'Registrant'),
            patch.object(MODULE, 'engine_requirements', return_value={
                'Engine': {'fixed_class_name': True, 'fields': [], 'methods': []},
            }),
            patch.object(MODULE, 'dex_classes', return_value=definitions),
            patch.object(MODULE, 'read_mapping', return_value=(mapping, members, {})),
        ):
            return MODULE.report(arguments)

    def test_baseline_cannot_hide_new_renamed_field(self):
        """旧模型基线不能让当前新增字段的混淆从失败变成通过。"""
        result = self.run_report(renamed_field=True)
        self.assertFalse(result['checks']['passed'])
        self.assertIn('newField', '\n'.join(result['checks']['failures']))
        self.assertEqual(['legacy', 'newField'], result['requirements'][MODEL]['fields'])

    def test_weaker_baseline_cannot_relax_current_class_identity(self):
        """基线中的宽松标记不能覆盖当前要求保留的通知模型类名。"""
        result = self.run_report(renamed_class=True, baseline_fixed=False)
        self.assertFalse(result['checks']['passed'])
        self.assertTrue(result['requirements'][MODEL]['fixed_class_name'])

    def test_fields_methods_and_identity_are_unioned_without_mutation(self):
        """历史字段、当前字段、方法和严格类名要求同时生效，输入保持原样。"""
        current = {'fixed_class_name': False, 'fields': ['newField'], 'methods': ['newMethod']}
        historical = {'fixed_class_name': True, 'fields': ['legacy'], 'methods': ['oldMethod']}
        before = copy.deepcopy((current, historical))
        self.assertEqual({
            'fixed_class_name': True,
            'fields': ['legacy', 'newField'],
            'methods': ['newMethod', 'oldMethod'],
        }, MODULE.merge_requirements(current, historical))
        self.assertEqual(before, (current, historical))
        self.assertEqual(historical, MODULE.merge_requirements(None, historical))

    def test_malformed_baseline_cannot_relax_requirements(self):
        """错误基准要求必须拒绝，不能把字符串等错误类型作为宽松集合使用。"""
        current = {'fixed_class_name': True, 'fields': [], 'methods': []}
        for historical in (
            {'fixed_class_name': 'false', 'fields': [], 'methods': []},
            {'fixed_class_name': True, 'fields': 'legacy', 'methods': []},
            {'fixed_class_name': True, 'fields': [], 'methods': [None]},
        ):
            with self.subTest(historical=historical):
                with self.assertRaises(ValueError):
                    MODULE.merge_requirements(current, historical)


if __name__ == '__main__':
    for stream in (sys.stdout, sys.stderr):
        if hasattr(stream, 'reconfigure'):
            stream.reconfigure(encoding='utf-8', errors='backslashreplace')
    unittest.main()
