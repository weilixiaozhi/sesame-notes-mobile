"""检查发布安装包的全部原生库，避免插件库引入其他进程架构。"""
import argparse
import sys
import traceback
import zipfile


def check_apk_architecture(path, abi):
    """只接受指定架构，并要求 Flutter 引擎与应用库均已打包。"""
    with zipfile.ZipFile(path) as archive:
        libraries = {name for name in archive.namelist() if name.startswith('lib/') and name.endswith('.so')}
    architectures = {name.split('/')[1] for name in libraries}
    if architectures != {abi}:
        raise ValueError(f'APK native architectures: {sorted(architectures)}, expected: {abi}')
    for library in ('libflutter.so', 'libapp.so'):
        if f'lib/{abi}/{library}' not in libraries:
            raise ValueError(f'APK missing native library: {library}')


def main():
    """命令行失败时输出可定位原因并返回非零退出码。"""
    parser = argparse.ArgumentParser()
    parser.add_argument('--apk', required=True)
    parser.add_argument('--abi', default='arm64-v8a')
    args = parser.parse_args()
    try:
        check_apk_architecture(args.apk, args.abi)
        print(f'APK architecture verified: {args.abi}')
        return 0
    except Exception:
        traceback.print_exc()
        return 1


if __name__ == '__main__':
    sys.exit(main())
