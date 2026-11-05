"""覆盖iOS环境隔离的有效配置、错误组合及共享Xcode方案。"""

import base64
import importlib.util
import re
import unittest
from pathlib import Path
from xml.etree import ElementTree

ROOT = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location('ios_environment', ROOT / 'scripts/ios/check_environment.py')
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


def definitions(*values: str) -> str:
    """按Flutter与Xcode共用格式编码编译参数。"""
    return ','.join(base64.b64encode(value.encode()).decode() for value in values)


class IosEnvironmentTest(unittest.TestCase):
    """保证测试/正式身份在全部构建模式中不能混用。"""

    def values(self, environment: str, configuration: str) -> dict[str, str]:
        """构造不含真实服务器或凭据的构建夹具。"""
        return {
            'SESAME_APP_ENV': environment,
            'CONFIGURATION': configuration,
            'PRODUCT_BUNDLE_IDENTIFIER': 'com.sesame.notes.test' if environment == 'test' else 'com.sesame.notes',
            'DART_DEFINES': definitions(f'APP_ENV={environment}'),
        }

    def test_all_environment_build_modes(self):
        """六种显式配置以及旧方案的安全默认组合均可通过。"""
        for mode in ('Debug', 'Profile', 'Release'):
            for environment in ('test', 'prod'):
                with self.subTest(mode=mode, environment=environment):
                    MODULE.validate_environment(self.values(environment, f'{mode}-{environment}'))
            MODULE.validate_environment(self.values('test' if mode == 'Debug' else 'prod', mode))

    def test_mixed_or_missing_identity_is_rejected(self):
        """错误环境、Bundle ID、缺参数和冲突参数在编译前失败。"""
        for override in (
            {'SESAME_APP_ENV': 'prod'},
            {'PRODUCT_BUNDLE_IDENTIFIER': 'com.sesame.notes'},
            {'DART_DEFINES': ''},
            {'DART_DEFINES': definitions('APP_ENV=test', 'APP_ENV=prod')},
            {'DART_DEFINES': 'not-valid-base64'},
            {'CONFIGURATION': 'Unrecognized'},
        ):
            with self.subTest(fields=list(override)):
                with self.assertRaises(ValueError):
                    MODULE.validate_environment({**self.values('test', 'Debug-test'), **override})

    def test_scheme_and_target_configuration_match(self):
        """共享方案指向六个真实配置，所有目标从环境设置读取应用身份。"""
        project = (ROOT / 'ios/Runner.xcodeproj/project.pbxproj').read_text(encoding='utf-8')
        for environment in ('test', 'prod'):
            scheme = ElementTree.parse(ROOT / f'ios/Runner.xcodeproj/xcshareddata/xcschemes/{environment}.xcscheme')
            expected = {'TestAction': 'Debug', 'LaunchAction': 'Debug', 'ProfileAction': 'Profile', 'AnalyzeAction': 'Debug', 'ArchiveAction': 'Release'}
            for action, mode in expected.items():
                self.assertEqual(f'{mode}-{environment}', scheme.find(action).attrib['buildConfiguration'])
                self.assertIn(f'name = "{mode}-{environment}";', project)
        self.assertEqual(9, project.count('PRODUCT_BUNDLE_IDENTIFIER = "$(SESAME_BUNDLE_IDENTIFIER)";'))
        self.assertIn('check_environment.py', project)
        for name, environment in [('Debug', 'Test'), ('Release', 'Prod'), ('DebugProd', 'Prod'), ('ReleaseTest', 'Test')]:
            text = (ROOT / f'ios/Flutter/{name}.xcconfig').read_text(encoding='utf-8')
            self.assertIn(f'#include "Environment{environment}.xcconfig"', text)
        identifiers = re.findall(r'^\s{2,}([0-9A-F]{24}) /\*.*\*/ = \{', project, re.M)
        self.assertEqual(len(identifiers), len(set(identifiers)))


if __name__ == '__main__':
    unittest.main()
