"""在Xcode编译Flutter前核对环境、应用身份和Dart参数，拒绝混用沙箱。"""

import base64
import binascii
import os
import sys
import traceback
from collections.abc import Mapping


def validate_environment(values: Mapping[str, str]) -> None:
    """验证所有Dart环境声明与Xcode配置及Bundle ID一致，不输出配置值。"""
    try:
        environment = values.get('SESAME_APP_ENV', '')
        if environment not in ('test', 'prod'):
            raise ValueError('iOS构建环境未配置，请使用共享test或prod方案。')
        configuration = values.get('CONFIGURATION', '')
        if configuration in ('Debug', 'Profile', 'Release'):
            expected = 'test' if configuration == 'Debug' else 'prod'
        elif configuration in tuple(
            f'{mode}-{flavor}'
            for mode in ('Debug', 'Profile', 'Release')
            for flavor in ('test', 'prod')
        ):
            expected = configuration.rsplit('-', 1)[1]
        else:
            raise ValueError('iOS构建配置不受支持，请选择test或prod方案。')
        if environment != expected:
            raise ValueError('iOS构建配置与环境不一致，请重新生成正确方案的配置。')
        bundle = 'com.sesame.notes.test' if expected == 'test' else 'com.sesame.notes'
        if values.get('PRODUCT_BUNDLE_IDENTIFIER') != bundle:
            raise ValueError('iOS应用身份与环境不一致，已阻止复用另一环境的沙箱。')

        declarations = []
        for encoded in values.get('DART_DEFINES', '').split(','):
            if not encoded:
                continue
            try:
                decoded = base64.b64decode(encoded, validate=True).decode('utf-8')
            except (binascii.Error, UnicodeDecodeError) as error:
                raise ValueError('Dart编译参数无法解码，请重新运行对应环境的Flutter构建。') from error
            if decoded.startswith('APP_ENV='):
                declarations.append(decoded.split('=', 1)[1])
        if not declarations or any(value != expected for value in declarations):
            raise ValueError('Dart环境与iOS应用身份不一致，已阻止编译。')
    except (TypeError, ValueError):
        raise


def main() -> int:
    """读取Xcode当前进程配置，失败时提供友好摘要及不含参数值的诊断。"""
    try:
        validate_environment(os.environ)
        print('iOS环境、Dart参数与应用身份校验通过。')
        return 0
    except Exception as error:
        print(f'iOS环境检查失败：{error}', file=sys.stderr)
        traceback.print_exc()
        return 1


if __name__ == '__main__':
    raise SystemExit(main())
