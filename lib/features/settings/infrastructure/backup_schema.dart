import 'package:sesame_notes/data/db.dart';

/// 备份只接受当前数据库结构，其他版本不能进入恢复流程。
bool supportsBackupSchema(int sourceVersion) =>
    sourceVersion == currentSchemaVersion;
