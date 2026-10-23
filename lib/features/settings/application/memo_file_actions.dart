import 'package:sesame_notes/shared/application/provider_reader.dart';
import 'package:sesame_notes/data/models/private_book.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:sesame_notes/data/models/memo_json.dart';
import 'package:sesame_notes/shared/providers/memo_repository_provider.dart';
import '../infrastructure/export_file_name.dart';

typedef MemoExportSnapshot = ({
  MemoJsonDocument document,
  PrivateBookTarget target,
});

/// 沿用仓储的单本快照与目标指纹，页面不另写序列化或身份校验。
Future<MemoExportSnapshot> prepareMemoExport(
  ProviderReader read,
  String id,
) async {
  final repo = read(memoTransferRepositoryProvider);
  final document = await repo.exportJson(id);
  return (document: document, target: await repo.target(id));
}

Future<void> validateMemoExport(
  ProviderReader read,
  MemoExportSnapshot snapshot,
) async {
  final repo = read(memoTransferRepositoryProvider);
  await repo.requireTarget(snapshot.target);
}

/// 写出备忘录导出文件。
///
/// 内容使用仓储的标准交换格式（`sesame-memos`）：本名与本子类型随文件一起
/// 携带，本子信封中的条目列表供备忘录文档读端与统一映射页读取。
/// [business]/[typeLabel] 为当前语言的业务名与本子类型名，用于自描述文件名。
Future<String> writeMemoExport(
  ProviderReader read,
  MemoExportSnapshot snapshot, {
  required String business,
  required String typeLabel,
  required Directory outputDirectory,
}) async {
  await validateMemoExport(read, snapshot);
  final book = snapshot.document.books.single.book;
  final file = File(
    p.join(
      outputDirectory.path,
      exportFileName(
        business: business,
        content: book.name,
        variant: typeLabel,
        extension: 'json',
        exportedAt: snapshot.document.exportedAt,
      ),
    ),
  );
  try {
    await file.writeAsBytes(snapshot.document.encode(), flush: true);
    await validateMemoExport(read, snapshot);
    return file.path;
  } catch (_) {
    if (await file.exists()) await file.delete();
    rethrow;
  }
}
