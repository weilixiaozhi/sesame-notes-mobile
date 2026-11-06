"""验证iOS环境隔离的有效配置和身份混用拒绝规则。"""

import base64
import importlib.util
import unittest
from pathlib import Path

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

if __name__ == '__main__':
    unittest.main()
