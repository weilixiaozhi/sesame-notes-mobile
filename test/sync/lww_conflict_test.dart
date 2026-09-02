// LWW 冲突解析测试（updated_at, device_id 字典序大者胜）。
//
// 需求锚点：
// - 远端更新晚于本地 → 远端胜（应用）；
// - 本地更新晚于远端 → 本地胜（跳过，保护未推送本地修改）；
// - 时间相同 → device_id 字典序大者胜；
// - 本地无该实体 → 直接应用（无冲突）。
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/sync/lww_conflict.dart';

void main() {
  group('LWW 冲突决策', () {
    final localDevice = 'aaaaaaaa-0000-4000-8000-000000000000';
    final remoteDevice = 'bbbbbbbb-0000-4000-8000-000000000000';

    test('远端 updated_at 更晚 → 远端胜', () {
      final decision = lwwShouldApply(
        localUpdatedAt: DateTime.utc(2026, 1, 1),
        localDeviceId: localDevice,
        remoteUpdatedAt: DateTime.utc(2026, 1, 2),
        remoteDeviceId: remoteDevice,
      );
      expect(decision, isTrue, reason: '远端时间更新，必须应用远端');
    });

    test('本地 updated_at 更晚 → 本地胜（跳过）', () {
      final decision = lwwShouldApply(
        localUpdatedAt: DateTime.utc(2026, 1, 3),
        localDeviceId: localDevice,
        remoteUpdatedAt: DateTime.utc(2026, 1, 2),
        remoteDeviceId: remoteDevice,
      );
      expect(decision, isFalse, reason: '本地时间更新，保护未推送的本地修改');
    });

    test('时间相同 → device_id 字典序大者胜', () {
      final same = DateTime.utc(2026, 1, 2);
      // remoteDevice (b...) > localDevice (a...) → 远端胜
      expect(
        lwwShouldApply(
          localUpdatedAt: same,
          localDeviceId: localDevice,
          remoteUpdatedAt: same,
          remoteDeviceId: remoteDevice,
        ),
        isTrue,
        reason: '时间相同按 device_id 字典序，远端 b > 本地 a',
      );
      // 反向：本地 b > 远端 a → 本地胜
      expect(
        lwwShouldApply(
          localUpdatedAt: same,
          localDeviceId: remoteDevice,
          remoteUpdatedAt: same,
          remoteDeviceId: localDevice,
        ),
        isFalse,
        reason: '时间相同按 device_id 字典序，本地 b > 远端 a',
      );
    });

    test('本地无实体（null 时间）→ 直接应用', () {
      expect(
        lwwShouldApply(
          localUpdatedAt: null,
          localDeviceId: localDevice,
          remoteUpdatedAt: DateTime.utc(2026, 1, 2),
          remoteDeviceId: remoteDevice,
        ),
        isTrue,
        reason: '本地不存在时无冲突，必须应用远端',
      );
    });
  });
}
