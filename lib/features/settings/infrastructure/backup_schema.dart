import 'package:sesame_notes/data/db.dart';

/// 结构 13 到 14 只新增可重建的备忘录图片表，业务表与列未变，
/// 因此上一版结构仍可按当前业务规则恢复；更早结构缺少当前列，不在此列。
const minimumRestorableBackupSchema = 13;

/// 备份支持当前结构及上一版结构，其他版本不能进入恢复流程。
bool supportsBackupSchema(int sourceVersion) =>
    sourceVersion >= minimumRestorableBackupSchema &&
    sourceVersion <= currentSchemaVersion;
