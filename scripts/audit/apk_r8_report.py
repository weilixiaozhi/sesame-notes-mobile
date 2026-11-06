"""只读测量 APK 的 DEX 与 R8 输出，核对实际引擎入口和通知模型名称。"""

import argparse
import hashlib
import json
from pathlib import Path
import re
import struct
import sys
import traceback
import zipfile


MODEL_PREFIX = 'com.dexterous.flutterlocalnotifications.models.'
APP_ENTRIES = (
    'com.sesame.notes.MainActivity',
    'com.sesame.notes.UpdateFileProvider',
    'com.sesame.notes.AppUpdateDownloadService',
    'com.sesame.notes.AppUpdateDownloadReceiver',
    'com.sesame.notes.AppUpdateInstalledReceiver',
    'com.sesame.notes.ReminderAlarmReceiver',
    'com.sesame.notes.FitnessRestAlarmService',
    'com.sesame.notes.FitnessRestAlarmReceiver',
)
REGISTRANT = 'io.flutter.plugins.GeneratedPluginRegistrant'
KEEP_ANNOTATION = 'Landroidx/annotation/Keep;'


class Reader:
    """带边界检查读取二进制，拒绝截断输入而不静默产生测量结果。"""

    def __init__(self, data, offset=0):
        """绑定不可变输入与游标，不修改 APK 或类文件。"""
        self.data = data
        self.offset = offset

    def take(self, size):
        """按长度读取一段数据，越界立即报告格式错误。"""
        if size < 0 or self.offset + size > len(self.data):
            raise ValueError('二进制输入已截断。')
        result = self.data[self.offset:self.offset + size]
        self.offset += size
        return result

    def integer(self, size):
        """Class 文件整数统一使用大端序。"""
        return int.from_bytes(self.take(size), 'big')

    def uleb(self):
        """读取 DEX 无符号变长整数，限制五字节避免损坏输入无限循环。"""
        value = 0
        for shift in range(0, 35, 7):
            byte = self.integer(1)
            value |= (byte & 0x7f) << shift
            if not byte & 0x80:
                return value
        raise ValueError('DEX 变长整数超出允许长度。')


def artifact(path):
    """只记录文件名、大小和摘要，不输出配置、签名、路径或业务内容。"""
    digest = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(block)
    return {'name': path.name, 'bytes': path.stat().st_size, 'sha256': digest.hexdigest()}


def annotations(data, constants):
    """解析类或成员顶层注解；嵌套值完整跳过，避免仅按常量池文本误判。"""
    reader = Reader(data)

    def annotation():
        """读取一个注解并越过其所有字段值。"""
        name = constants[reader.integer(2)]
        for _ in range(reader.integer(2)):
            reader.integer(2)
            element()
        return name

    def element():
        """按 JVM 注解值标签跳过常量、枚举、嵌套注解或数组。"""
        tag = chr(reader.integer(1))
        if tag in 'BCDFIJSZsc':
            reader.integer(2)
        elif tag == 'e':
            reader.take(4)
        elif tag == '@':
            annotation()
        elif tag == '[':
            for _ in range(reader.integer(2)):
                element()
        else:
            raise ValueError('不支持的 JVM 注解值。')

    return {annotation() for _ in range(reader.integer(2))}


def engine_requirements(path):
    """从本次 SDK 的 class 注解和 native 标记生成精确保留要求。"""
    result = {}
    with zipfile.ZipFile(path) as archive:
        for entry in archive.namelist():
            if not entry.endswith('.class') or not entry.startswith('io/flutter/'):
                continue
            reader = Reader(archive.read(entry))
            if reader.take(4) != b'\xca\xfe\xba\xbe':
                raise ValueError('Flutter JAR 中存在无效 class。')
            reader.take(4)
            constants = [None] * reader.integer(2)
            index = 1
            while index < len(constants):
                tag = reader.integer(1)
                if tag == 1:
                    constants[index] = reader.take(reader.integer(2)).decode('utf-8', 'replace')
                elif tag in (5, 6):
                    reader.take(8)
                    index += 1
                elif tag in (3, 4, 9, 10, 11, 12, 17, 18):
                    reader.take(4)
                elif tag in (7, 8, 16, 19, 20):
                    constants[index] = reader.integer(2)
                elif tag == 15:
                    reader.take(3)
                else:
                    raise ValueError('Flutter JAR 中存在未知常量池类型。')
                index += 1
            reader.integer(2)
            name = constants[constants[reader.integer(2)]].replace('/', '.')
            reader.integer(2)
            reader.take(reader.integer(2) * 2)

            def attributes():
                """读取本节点属性中的注解，其他属性只校验长度。"""
                found = set()
                for _ in range(reader.integer(2)):
                    kind = constants[reader.integer(2)]
                    payload = reader.take(reader.integer(4))
                    if kind in ('RuntimeVisibleAnnotations', 'RuntimeInvisibleAnnotations'):
                        found.update(annotations(payload, constants))
                return found

            members = []
            for kind in ('field', 'method'):
                for _ in range(reader.integer(2)):
                    flags = reader.integer(2)
                    member = constants[reader.integer(2)]
                    descriptor = constants[reader.integer(2)]
                    marked = KEEP_ANNOTATION in attributes()
                    members.append((kind, member, descriptor, marked, bool(flags & 0x100)))
            class_marked = KEEP_ANNOTATION in attributes()
            expected = {'fixed_class_name': class_marked, 'fields': [], 'methods': []}
            for kind, member, descriptor, marked, native in members:
                if native:
                    expected['fixed_class_name'] = True
                if (class_marked or marked or native) and member not in ('<init>', '<clinit>'):
                    expected['fields' if kind == 'field' else 'methods'].append(member)
            if expected['fixed_class_name'] or expected['fields'] or expected['methods']:
                expected['fields'] = sorted(set(expected['fields']))
                expected['methods'] = sorted(set(expected['methods']))
                result[name] = expected
    if not result or 'io.flutter.embedding.engine.FlutterJNI' not in result:
        raise ValueError('未从 Flutter JAR 读取到 JNI/Keep 入口。')
    return result


def dex_classes(data):
    """读取 DEX 定义表和 class_data，仅统计真正定义的类与成员。"""
    if len(data) < 112 or not re.fullmatch(rb'dex\n0(?:3[5-9]|40)\x00', data[:8]):
        raise ValueError('APK 中存在不支持的 DEX 头。')
    if struct.unpack_from('<I', data, 40)[0] != 0x12345678:
        raise ValueError('DEX 字节序不受支持。')

    def table(header_offset, width):
        """校验 DEX 表的完整范围，再返回表项计数与起点。"""
        count, offset = struct.unpack_from('<II', data, header_offset)
        if offset + count * width > len(data):
            raise ValueError('DEX 表范围已截断。')
        return count, offset

    count, offset = table(56, 4)
    strings = []
    for index in range(count):
        start = struct.unpack_from('<I', data, offset + index * 4)[0]
        reader = Reader(data, start)
        reader.uleb()
        end = data.find(b'\0', reader.offset)
        if end < 0:
            raise ValueError('DEX 字符串缺少结束符。')
        strings.append(data[reader.offset:end].decode('utf-8', 'replace'))
    count, offset = table(64, 4)
    types = [strings[struct.unpack_from('<I', data, offset + index * 4)[0]] for index in range(count)]
    fields = []
    methods = []
    for header, destination in ((80, fields), (88, methods)):
        count, offset = table(header, 8)
        for index in range(count):
            owner, _, name = struct.unpack_from('<HHI', data, offset + index * 8)
            destination.append((types[owner], strings[name]))
    count, offset = table(96, 32)
    result = {}
    for index in range(count):
        values = struct.unpack_from('<8I', data, offset + index * 32)
        descriptor = types[values[0]]
        name = descriptor[1:-1].replace('/', '.')
        members = {'fields': set(), 'methods': set()}
        if values[6]:
            reader = Reader(data, values[6])
            sizes = [reader.uleb() for _ in range(4)]
            for group, size in enumerate(sizes):
                member_index = 0
                for _ in range(size):
                    member_index += reader.uleb()
                    reader.uleb()
                    source = fields if group < 2 else methods
                    owner, member = source[member_index]
                    if owner != descriptor:
                        raise ValueError('DEX 成员归属与类定义不一致。')
                    members['fields' if group < 2 else 'methods'].add(member)
                    if group >= 2:
                        reader.uleb()
        result[name] = members
    return result


def group_name(name):
    """聚合命名空间，避免把全部符号或配置内容写入报告。"""
    if name.startswith(MODEL_PREFIX):
        return 'notification_models'
    for prefix, label in (('io.flutter.', 'flutter'), ('com.dexterous.', 'notification_implementation'), ('com.sesame.notes.', 'app')):
        if name.startswith(prefix):
            return label
    return 'other'


def read_mapping(path):
    """读取原名到产物名，并单独保留通知持久字段和方法的改名信息。"""
    classes, members, counts = {}, {}, {}
    owner = None
    for line in path.read_text(encoding='utf-8').splitlines():
        match = re.fullmatch(r'(\S+) -> (\S+):', line)
        if match:
            owner, target = match.groups()
            classes[owner] = target
            label = group_name(owner)
            counts[label] = counts.get(label, 0) + 1
        elif owner and line.startswith(' ') and ' -> ' in line:
            original, target = line.strip().rsplit(' -> ', 1)
            declaration = re.sub(r'^\d+:\d+:', '', original)
            if '(' in declaration:
                name = declaration.split('(', 1)[0].split(' ')[-1]
                kind = 'methods'
            else:
                name = declaration.split(' ')[-1]
                kind = 'fields'
            if '.' not in name:
                members.setdefault(owner, {}).setdefault(kind, {}).setdefault(name, set()).add(target)
    return classes, members, counts


def merge_requirements(current, historical):
    """当前与历史保护取并集，任一版本要求固定类名时都必须保留。"""
    if current is None:
        current = {'fixed_class_name': False, 'fields': [], 'methods': []}
    # 缺字段、错误标记和字符串集合都必须拒绝，不能被转换成宽松的保护要求。
    for requirement in (current, historical):
        if (
            not isinstance(requirement, dict)
            or set(requirement) != {'fixed_class_name', 'fields', 'methods'}
            or type(requirement['fixed_class_name']) is not bool
            or any(
                not isinstance(requirement[kind], list)
                or any(not isinstance(name, str) or not name for name in requirement[kind])
                for kind in ('fields', 'methods')
            )
        ):
            raise ValueError('通知模型保护要求格式无效，请检查基准报告。')
    # 成员保留双方完整集合，类名保护只允许增强，不能由另一份输入降低。
    return {
        'fixed_class_name': current['fixed_class_name'] or historical['fixed_class_name'],
        'fields': sorted(set(current['fields']) | set(historical['fields'])),
        'methods': sorted(set(current['methods']) | set(historical['methods'])),
    }


def report(args):
    """关联实际 DEX、mapping 和 SDK 入口，产出有界测量及名称保护结果。"""
    apk, mapping_dir = Path(args.apk), Path(args.mapping_dir)
    artifacts = {'apk': artifact(apk), 'engine_jar': artifact(Path(args.engine_jar))}
    for name in ('mapping', 'seeds', 'usage', 'configuration'):
        artifacts[name] = artifact(mapping_dir / (name + '.txt'))
    definitions, dex = {}, []
    with zipfile.ZipFile(apk) as archive:
        for entry in archive.infolist():
            if re.fullmatch(r'classes(?:[2-9]|[1-9]\d+)?.dex', entry.filename):
                data = archive.read(entry)
                classes = dex_classes(data)
                if definitions.keys() & classes.keys():
                    raise ValueError('APK 的多个 DEX 定义了同名类。')
                definitions.update(classes)
                dex.append({'name': entry.filename, 'raw_bytes': entry.file_size, 'zip_bytes': entry.compress_size, 'classes': len(classes)})
    if not dex:
        raise ValueError('APK 未包含 classes.dex。')
    mapping, member_mapping, mapping_counts = read_mapping(mapping_dir / 'mapping.txt')
    requirements = engine_requirements(Path(args.engine_jar))
    for name in APP_ENTRIES:
        requirements[name] = {'fixed_class_name': True, 'fields': [], 'methods': []}
    requirements[REGISTRANT] = {'fixed_class_name': True, 'fields': [], 'methods': ['registerWith']}
    # R8 自身合成的实现类名不是通知缓存中的模型身份。
    model_names = sorted(name for name in mapping if name.startswith(MODEL_PREFIX) and '$$' not in name)
    for name in model_names:
        requirements[name] = {'fixed_class_name': True, 'fields': sorted(member_mapping.get(name, {}).get('fields', {})), 'methods': []}
    if not any(name.endswith('.NotificationDetails') for name in model_names):
        raise ValueError('mapping 缺少通知持久化模型，不能确认序列化入口。')
    baseline = None
    if args.baseline:
        baseline = json.loads(Path(args.baseline).read_text(encoding='utf-8'))
        if baseline.get('format') != 'sesame-notes.apk-r8-report.v1':
            raise ValueError('基准 JSON 格式不受支持。')
        # 历史模型字段是升级兼容边界，不能只用新产物中剩余的字段自证完整。
        for name, expected in baseline['requirements'].items():
            if name.startswith(MODEL_PREFIX):
                requirements[name] = merge_requirements(requirements.get(name), expected)
    failures = []
    for name, expected in requirements.items():
        target = mapping.get(name)
        if target is None or target not in definitions:
            failures.append(name + ': 缺少定义或 mapping')
            continue
        if expected['fixed_class_name'] and target != name:
            failures.append(name + ': 类名已改变')
        for kind in ('fields', 'methods'):
            for member in expected[kind]:
                renamed = member_mapping.get(name, {}).get(kind, {}).get(member, set())
                if member not in definitions[target][kind] or (renamed and renamed != {member}):
                    failures.append(name + '.' + member + ': 成员名或定义未保留')
    seeds = {'classes': 0, 'members': 0, 'groups': {}}
    for line in (mapping_dir / 'seeds.txt').read_text(encoding='utf-8').splitlines():
        if line and not line.startswith('#'):
            kind = 'members' if ':' in line else 'classes'
            seeds[kind] += 1
            label = group_name(line.split(':', 1)[0])
            seeds['groups'][label] = seeds['groups'].get(label, 0) + 1
    output = {'format': 'sesame-notes.apk-r8-report.v1', 'artifacts': artifacts,
              'dex': {'files': dex, 'raw_bytes': sum(item['raw_bytes'] for item in dex), 'zip_bytes': sum(item['zip_bytes'] for item in dex), 'classes': len(definitions)},
              'r8': {'seeds': seeds, 'mapping_classes': len(mapping), 'renamed_classes': sum(name != target for name, target in mapping.items()), 'mapping_groups': mapping_counts},
              'requirements': requirements, 'checks': {'passed': not failures, 'failures': failures},
              'limits': ['seeds 是保留根符号清单，不等于 DEX 定义或运行频率。', 'mapping 与 APK 的关键入口核对不能证明二者来自同一轮完整构建。', 'DEX 字节差异不是内存、启动或运行性能结论；仍需压缩正式包的实机入口和历史通知恢复验收。']}
    if baseline:
        output['comparison'] = {'baseline_apk_sha256': baseline['artifacts']['apk']['sha256'],
                                'same_engine_jar': artifacts['engine_jar']['sha256'] == baseline['artifacts']['engine_jar']['sha256'],
                                'apk_bytes_delta': artifacts['apk']['bytes'] - baseline['artifacts']['apk']['bytes'],
                                'dex_raw_bytes_delta': output['dex']['raw_bytes'] - baseline['dex']['raw_bytes'],
                                'dex_zip_bytes_delta': output['dex']['zip_bytes'] - baseline['dex']['zip_bytes'],
                                'seeds_classes_delta': seeds['classes'] - baseline['r8']['seeds']['classes'],
                                'seeds_members_delta': seeds['members'] - baseline['r8']['seeds']['members']}
    return output


def main():
    """输入失败输出详细诊断，保护检查失败返回非零且从不覆盖既有报告。"""
    # Windows 重定向可能使用系统单字节编码，统一保证中文失败诊断可写出。
    for stream in (sys.stdout, sys.stderr):
        if hasattr(stream, 'reconfigure'):
            stream.reconfigure(encoding='utf-8', errors='backslashreplace')
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--apk', required=True)
    parser.add_argument('--mapping-dir', required=True)
    parser.add_argument('--engine-jar', required=True)
    parser.add_argument('--baseline', help='同一工具生成的旧包 JSON，额外核对历史通知模型字段')
    parser.add_argument('--json-output', help='只在不存在的新文件中保存完整测量报告')
    args = parser.parse_args()
    try:
        output = report(args)
        if args.json_output:
            destination = Path(args.json_output).resolve()
            if not destination.is_relative_to((Path.cwd() / 'Temp').resolve()):
                raise ValueError('测量中间报告必须保存到当前仓库根目录的 Temp 中。')
            with destination.open('x', encoding='utf-8', newline='\n') as stream:
                json.dump(output, stream, ensure_ascii=False, indent=2)
                stream.write('\n')
        summary = {key: output[key] for key in ('dex', 'r8', 'checks')}
        if 'comparison' in output:
            summary['comparison'] = output['comparison']
        print(json.dumps(summary, ensure_ascii=False, indent=2))
        return 0 if output['checks']['passed'] else 1
    except Exception:
        print('APK/R8 只读测量未完成，请检查输入文件及详细诊断。', file=sys.stderr)
        traceback.print_exc()
        return 2


if __name__ == '__main__':
    sys.exit(main())
