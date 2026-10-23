"""发布原生架构检查回归，测试文件只放在仓库 Temp 目录。"""
import importlib.util
from pathlib import Path
import tempfile
import unittest
import zipfile

ROOT = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location('apk_architecture', ROOT / 'scripts/check_apk_architecture.py')
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class ApkArchitectureTest(unittest.TestCase):
    """验证正确发布包、插件混入架构和缺少引擎的失败路径。"""

    def test_architecture(self):
        """使用小型 ZIP 夹具验证每一种实际打包边界。"""
        temp_root = ROOT / 'Temp'
        temp_root.mkdir(exist_ok=True)
        with tempfile.TemporaryDirectory(prefix='apk-architecture-', dir=temp_root) as folder:
            path = Path(folder) / 'test.apk'
            for extra, accepted in (([], True), (['lib/x86_64/libplugin.so'], False)):
                with zipfile.ZipFile(path, 'w') as archive:
                    for name in ['lib/arm64-v8a/libflutter.so', 'lib/arm64-v8a/libapp.so', *extra]:
                        archive.writestr(name, b'test')
                if accepted:
                    MODULE.check_apk_architecture(path, 'arm64-v8a')
                else:
                    with self.assertRaises(ValueError):
                        MODULE.check_apk_architecture(path, 'arm64-v8a')
            with zipfile.ZipFile(path, 'w') as archive:
                archive.writestr('lib/arm64-v8a/libplugin.so', b'test')
            with self.assertRaises(ValueError):
                MODULE.check_apk_architecture(path, 'arm64-v8a')


if __name__ == '__main__':
    unittest.main()
