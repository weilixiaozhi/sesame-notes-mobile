import 'package:sesame_notes/data/db.dart';

/// 结构 12 到 13 只新增可重建的云端历史缓存表，业务表与列未变，
/// 因此上一版结构仍可按当前业务规则恢复；更早结构缺少当前列，不在此列。
const minimumRestorableBackupSchema = 12;

/// 备份支持当前结构及上一版结构，其他版本不能进入恢复流程。
bool supportsBackupSchema(int sourceVersion) =>
    sourceVersion >= minimumRestorableBackupSchema &&
    sourceVersion <= currentSchemaVersion;
